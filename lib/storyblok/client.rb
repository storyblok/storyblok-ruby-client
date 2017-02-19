require_relative 'request'
require_relative 'links'

require 'rest-client'
require 'logger'

module Storyblok
  class Client
    DEFAULT_CONFIGURATION = {
      secure: true,
      api_url: 'api.storyblok.com',
      api_version: 1,
      logger: false,
      log_level: Logger::INFO,
      version: 'draft',
      cache_version: Time.now.to_i
    }

    attr_reader :configuration, :logger

    # @param [Hash] given_configuration
    # @option given_configuration [String] :token Required
    # @option given_configuration [String] :api_url
    # @option given_configuration [Number] :api_version
    # @option given_configuration [false, ::Logger] :logger
    # @option given_configuration [::Logger::DEBUG, ::Logger::INFO, ::Logger::WARN, ::Logger::ERROR] :log_level
    def initialize(given_configuration = {})
      @configuration = default_configuration.merge(given_configuration)
      validate_configuration!
      setup_logger
    end

    # Gets a collection of stories
    #
    # @param [Hash] query
    #
    # @return [Hash]
    def stories(query = {})
      Request.new(self, '/cdn/stories', query).get
    end

    # Gets a specific story
    #
    # @param [String] id
    # @param [Hash] query
    #
    # @return [Hash]
    def story(id, query = {})
      Request.new(self, '/cdn/stories', query, id).get
    end

    # Gets a collection of datasource entries
    #
    # @param [Hash] query
    #
    # @return [Hash]
    def datasource_entries(query = {})
      Request.new(self, '/cdn/datasource_entries', query).get
    end

    # Gets a collection of tags
    #
    # @param [Hash] query
    #
    # @return [Hash]
    def tags(query = {})
      Request.new(self, '/cdn/tags', query).get
    end

    # Gets a collection of links
    #
    # @param [Hash] query
    #
    # @return [Hash]
    def links(query = {})
      Links.new(Request.new(self, '/cdn/links', query).get)
    end

    def get(request)
      endpoint = base_url + request.url
      query = request_query(request.query)
      query_string = build_nested_query(query)

      if Cache.client.nil?
        result = run_request(endpoint, query_string)
      else
        cache_key = 'storyblok:' + configuration[:token] + ':' + request.url + ':' + Base64.encode64(query_string)
        cache_time = 60 * 60 * 2

        result = Cache.client.cache(cache_key, cache_time) do
          run_request(endpoint, query)
        end
      end

      JSON.parse(result)
    end

    private

    def run_request(endpoint, query_string)
      logger.info(request: { endpoint: endpoint, query: query_string }) if logger
      res = RestClient.get "#{endpoint}?#{query_string}"

      {headers: res.headers, data: JSON.parse(res.body)}.to_json
    end

    # Patches a query hash with the client configurations for queries
    def request_query(query)
      query[:token] = configuration[:token]
      query[:version] = configuration[:version] if query[:version].nil?
      query[:cv] = configuration[:cache_version] if query[:cache_version].nil?
      query
    end

    # Returns the base url for all of the client's requests
    def base_url
      "http#{configuration[:secure] ? 's' : ''}://#{configuration[:api_url]}/v#{configuration[:api_version]}"
    end

    def default_configuration
      DEFAULT_CONFIGURATION.dup
    end

    def setup_logger
      @logger = configuration[:logger]
      logger.level = configuration[:log_level] if logger
    end

    def validate_configuration!
      fail ArgumentError, 'You will need to initialize a client with an :token' if configuration[:token].empty?
      fail ArgumentError, 'The client configuration needs to contain an :api_url' if configuration[:api_url].empty?
      fail ArgumentError, 'The :api_version must be a positive number' unless configuration[:api_version].to_i >= 0
    end

    def build_nested_query(value, prefix = nil)
      case value
      when Array
        value.map { |v|
          build_nested_query(v, "#{prefix}[]")
        }.join("&")
      when Hash
        value.map { |k, v|
          build_nested_query(v, prefix ? "#{prefix}[#{URI.encode_www_form_component(k)}]" : URI.encode_www_form_component(k))
        }.reject(&:empty?).join('&')
      when nil
        prefix
      else
        raise ArgumentError, "value must be a Hash" if prefix.nil?
        "#{prefix}=#{URI.encode_www_form_component(value)}"
      end
    end
  end
end
