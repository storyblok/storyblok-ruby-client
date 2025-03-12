require_relative 'request'
require_relative 'links'

require 'storyblok/richtext'
require 'rest-client'
require 'logger'
require 'base64'
require 'json'

module Storyblok
  class Client
    DEFAULT_CONFIGURATION = {
      secure: true,
      api_version: 2,
      logger: false,
      log_level: Logger::INFO,
      version: 'draft',
      # :nocov:
      component_resolver: ->(component, data) { '' },
      # :nocov:
      cache_version: Time.now.to_i,
      cache: nil,
      request_type: nil
    }

    attr_reader :configuration, :logger
    attr_accessor :cache_version

    # @param [Hash] given_configuration
    # @option given_configuration [String] :token Required if oauth_token is not set
    # @option given_configuration [String] :oauth_token Required if token is not set
    # @option given_configuration [String] :api_url
    # @option given_configuration [Proc] :component_resolver
    # @option given_configuration [Number] :api_version
    # @option given_configuration [String] :api_region
    # @option given_configuration [false, ::Logger] :logger
    # @option given_configuration [String] :token Required if oauth_token is not set
    # @option given_configuration [String] :request_type
    def initialize(given_configuration = {})
      @configuration = default_configuration.merge(given_configuration)
      @cache_version = '0'
      validate_configuration!

      if configuration[:oauth_token]
        @configuration[:api_version] = 1
        @rest_client = RestClient::Resource.new(
          base_url,
          headers: {
            authorization: configuration[:oauth_token],
            'SB-Agent-Version': Storyblok::VERSION,
            'SB-Agent': 'SB-RB'
          }
        )
      end

      @renderer = Richtext::HtmlRenderer.new
      @renderer.set_component_resolver(@configuration[:component_resolver])
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
      Request.new(self, '/cdn/spaces/me', query, nil, true).get
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
      run_management_request(:post, path, payload.to_json, additional_headers.merge({content_type: :json}))
    end

    def put(path, payload, additional_headers = {})
      run_management_request(:put, path, payload.to_json, additional_headers.merge({content_type: :json}))
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

    def cached_get(request, bypass_cache = false)
      endpoint = base_url + request.url
      query = request_query(request.query)
      query_string = build_nested_query(query)

      if cache.nil? || bypass_cache || query[:version] == 'draft'
        result = run_request(endpoint, query_string)
      else
        cache_key = 'storyblok:' + configuration[:token] + ':v:' + query[:cv] + ':' + request.url + ':' + Base64.encode64(query_string)

        result = cache.cache(cache_key) do
          run_request(endpoint, query_string)
        end
      end

      result = JSON.parse(result)

      if !result.dig('data', 'story').nil? || !result.dig('data', 'stories').nil?
        result = resolve_stories(result, query)
      end

      result
    end

    def flush
      unless cache.nil?
        cache.set('storyblok:' + configuration[:token] + ':version', space['data']['space']['version'])
      end
    end

    # Returns html from richtext field data
    #
    # @param [Hash] :data
    #
    # @return [String]
    def render data
      @renderer.render(data)
    end

    # Sets component resolver
    #
    # @param [Proc] :component_resolver
    #
    # @return [nil]
    def set_component_resolver component_resolver
      @renderer.set_component_resolver(component_resolver)
    end

    private
      def parse_result(res)
        { 'headers' => res.headers, 'data' => JSON.parse(res.body) }
      end

      def run_request(endpoint, query_string)
        logger.info(request: { endpoint: endpoint, query: query_string }) if logger

        retries_left = 3

        begin
          headers = {
            'SB-Agent-Version': Storyblok::VERSION,
            'SB-Agent': 'SB-RB'
          }

          headers['X-Request-Type'] = @configuration[:request_type] unless @configuration[:request_type].to_s.empty?

          # rubocop:disable Lint/UselessAssignment
          res = RestClient.get(
            "#{endpoint}?#{query_string}",
            headers = headers
          )
          # rubocop:enable Lint/UselessAssignment
        rescue RestClient::TooManyRequests
          if retries_left != 0
            retries_left -= 1
            logger.info("Too many requests. Retry nr. #{(3 - retries_left).to_s} of max. 3 times.") if logger
            sleep(0.5)
            retry
          end

          raise
        end

        body = JSON.parse(res.body)
        self.cache_version = body['cv'] if body['cv']

        unless cache.nil?
          cache.set('storyblok:' + configuration[:token] + ':version', cache_version)
        end

        { 'headers' => res.headers, 'data' => body }.to_json
      end

      # Patches a query hash with the client configurations for queries
      def request_query(query)
        query[:token] = configuration[:token] if query[:token].nil?
        query[:version] = configuration[:version] if query[:version].nil?

        unless cache.nil?
          query[:cv] = (cache.get('storyblok:' + configuration[:token] + ':version') or cache_version) if query[:cv].nil?
        else
          query[:cv] = cache_version if query[:cv].nil?
        end

        query
      end

      # Returns the base url for all of the client's requests
      def base_url
        if !configuration[:api_url]
          region = configuration[:api_region] ? "-#{configuration[:api_region]}" : ""
          "http#{configuration[:secure] ? 's' : ''}://api#{region}.storyblok.com/v#{configuration[:api_version]}"
        else
          "http#{configuration[:secure] ? 's' : ''}://#{configuration[:api_url]}/v#{configuration[:api_version]}"
        end
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
            build_nested_query(v,
                               prefix ? "#{prefix}[#{URI.encode_www_form_component(k)}]" : URI.encode_www_form_component(k))
          }.reject(&:empty?).join('&')
        when nil
          prefix
        else
          raise ArgumentError, "value must be a Hash" if prefix.nil?

          "#{prefix}=#{URI.encode_www_form_component(value)}"
        end
      end

      def resolve_stories(result, params)
        data = result['data']
        rels = data['rels']
        links = data['links']
        resolve_relations = params[:resolve_relations] || params["resolve_relations"]

        if data['stories'].nil?
          find_and_fill_relations(data.dig('story', 'content'), resolve_relations, rels)
          find_and_fill_links(data.dig('story', 'content'), links)
        else
          data['stories'].each do |story|
            find_and_fill_relations(story['content'], resolve_relations, rels)
            find_and_fill_links(story['content'], links)
          end
        end

        result
      end

      def find_and_fill_links(content, links)
        return if content.nil? || links.nil? || links.size.zero?

        if content.is_a? Array
          content.each do |item|
            find_and_fill_links(item, links)
          end
        elsif content.is_a? Hash
          content['story'] = nil
          content.each do |_k, value|
            if !content['fieldtype'].nil?
              if content['fieldtype'] == 'multilink' && content['linktype'] == 'story'
                id =
                  if content['id'].is_a? String
                    content['id']
                  elsif content['uuid'].is_a? String
                    content['uuid']
                  end

                links.each do |link|
                  if link['uuid'] == id
                    content['story'] = link
                    break
                  end
                end
              end
            end

            find_and_fill_links(value, links)
          end
          content.delete('story') if content['story'].nil?
        end
      end

      def find_and_fill_relations(content, relation_params, rels)
        return if content.nil? || rels.nil? || rels.size.zero?

        if content.is_a? Array
          content.each do |item|
            find_and_fill_relations(item, relation_params, rels)
          end
        elsif content.is_a? Hash
          content.each do |_k, value|
            if !content['component'].nil? && !content['_uid'].nil?
              relation_params.split(',').each do |relation|
                component, field_name = relation.split('.')

                if (content['component'] == component) && !content[field_name].nil?
                  rels.each do |rel|
                    index = content[field_name].index(rel['uuid'])
                    if !index.nil?
                      content[field_name][index] = rel
                    end
                  end
                end
              end
            end

            find_and_fill_relations(value, relation_params, rels)
          end
        end
      end
  end
end
