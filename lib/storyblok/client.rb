require_relative 'request'
require_relative 'links'

require 'rest-client'
require 'logger'
require 'base64'
require 'json'

module Storyblok
  class Client
    DEFAULT_CONFIGURATION = {
      secure: true,
      api_url: 'api.storyblok.com',
      api_version: 1,
      logger: false,
      log_level: Logger::INFO,
      version: 'draft',
      cache_version: Time.now.to_i,
      cache: nil,
    }

    attr_reader :configuration, :logger

    # @param [Hash] given_configuration
    # @option given_configuration [String] :token Required if oauth_token is not set
    # @option given_configuration [String] :oauth_token Required if token is not set
    # @option given_configuration [String] :api_url
    # @option given_configuration [Number] :api_version
    # @option given_configuration [false, ::Logger] :logger
    # @option given_configuration [::Logger::DEBUG, ::Logger::INFO, ::Logger::WARN, ::Logger::ERROR] :log_level
    def initialize(given_configuration = {})
      @configuration = default_configuration.merge(given_configuration)
      validate_configuration!

      if configuration[:oauth_token]
        @rest_client = RestClient::Resource.new(base_url, :headers => {
          :authorization => configuration[:oauth_token]
        })
      end

      setup_logger
    end

    # Dynamic cdn endpoint call
    #
    # @param [String] id
    # @param [Hash] query
    #
    # @return [Hash]
    def get_from_cdn(slug, query = {}, id = nil)
      Request.new(self, "/cdn/#{slug}", query, id).get
    end

    # Gets the space info
    #
    # @param [Hash] query
    #
    # @return [Hash]
    def space(query = {})
      Request.new(self, '/cdn/spaces/me', query).get
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

    # Gets a collection of datasources
    #
    # @param [Hash] query
    #
    # @return [Hash]
    def datasources(query = {})
      Request.new(self, '/cdn/datasources', query).get
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
      Request.new(self, '/cdn/links', query).get
    end

    # Gets a link tree
    #
    # @param [Hash] query
    #
    # @return [Hash]
    def tree(query = {})
      Links.new(Request.new(self, '/cdn/links', query).get).as_tree
    end

    def post(path, payload, additional_headers = {})
      run_management_request(:post, path, payload, additional_headers)
    end

    def put(path, payload, additional_headers = {})
      run_management_request(:put, path, payload, additional_headers)
    end

    def delete(path, additional_headers = {})
      run_management_request(:delete, path, nil, additional_headers)
    end

    def get(path, additional_headers = {})
      run_management_request(:get, path, nil, additional_headers)
    end

    def run_management_request(action, path, payload = {}, additional_headers = {})
      logger.info(request: { path: path, action: action }) if logger
      retries_left = 3

      begin
        if [:post, :put].include?(action)
          res = @rest_client[path].send(action, payload, additional_headers)
        else
          res = @rest_client[path].send(action, additional_headers)
        end
      rescue RestClient::TooManyRequests
        if retries_left != 0
          retries_left -= 1
          logger.info("Too many requests. Retry nr. #{(3 - retries_left).to_s} of max. 3 times.") if logger
          sleep(0.5)
          retry
        end

        raise
      end

      parse_result(res)
    end

    def cached_get(request)
      endpoint = base_url + request.url
      query = request_query(request.query)
      query_string = build_nested_query(query)

      if cache.nil?
        result = run_request(endpoint, query_string)
      else
        version = cache.get('storyblok:' + configuration[:token] + ':version') || '0'
        cache_key = 'storyblok:' + configuration[:token] + ':v:' + version + ':' + request.url + ':' + Base64.encode64(query_string)

        result = cache.cache(cache_key) do
          run_request(endpoint, query_string)
        end
      end

      JSON.parse(result)
    end

    def flush
      unless cache.nil?
        cache.set('storyblok:' + configuration[:token] + ':version', Time.now.to_i.to_s)
      end
    end

    private

    def parse_result(res)
      {'headers' => res.headers, 'data' => JSON.parse(res.body)}
    end

    def run_request(endpoint, query_string)
      logger.info(request: { endpoint: endpoint, query: query_string }) if logger

      retries_left = 3

      begin
        res = RestClient.get "#{endpoint}?#{query_string}"
      rescue RestClient::TooManyRequests
        if retries_left != 0
          retries_left -= 1
          logger.info("Too many requests. Retry nr. #{(3 - retries_left).to_s} of max. 3 times.") if logger
          sleep(0.5)
          retry
        end

        raise
      end

      {'headers' => res.headers, 'data' => JSON.parse(res.body)}.to_json
    end

    # Patches a query hash with the client configurations for queries
    def request_query(query)
      query[:token] = configuration[:token] if query[:token].nil?
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

    def cache
      configuration[:cache]
    end

    def setup_logger
      @logger = configuration[:logger]
      logger.level = configuration[:log_level] if logger
    end

    def validate_configuration!
      fail ArgumentError, 'You will need to initialize a client with an :token or :oauth_token' if !configuration[:token] and !configuration[:oauth_token]
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
