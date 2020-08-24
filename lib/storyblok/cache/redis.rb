module Storyblok
  module Cache
    class Redis
      DEFAULT_CONFIGURATION = {
        ttl: 60 * 60 * 24
      }.freeze

      attr_reader :redis

      def initialize(*args)
        options = args.last.is_a?(::Hash) ? args.pop : {}

        @redis = options.delete(:redis) || begin
          if defined?(::Redis)
            ::Redis.current
          else
            raise "Redis.current could not be found. Supply :redis option or make sure Redis.current is available."
          end
        end

        @options = DEFAULT_CONFIGURATION.merge(options)
      end

      def cache(key, expire = nil)
        if expire == 0
          return yield(self)
        end

        expire ||= @options[:ttl]

        if (value = get(key)).nil?
          value = yield(self)
          set(key, value, expire)
        end

        value
      end

      def get(key)
        @redis.get(key)
      end

      def set(key, value, expire = false)
        if expire
          @redis.setex(key, expire, value)
        else
          @redis.set(key, value)
        end
      end

    end
  end
end
