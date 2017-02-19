module Storyblok
  class Cache
    def self.client=(client)
      @client = client
    end

    def self.client
      @client
    end

    def cache(key, expire = nil)
      if expire == 0
        return yield(self)
      end

      if (value = @client.get(key)).nil?
        value = yield(self)
        @client.set(key, value)
        @client.expire(key, expire) if expire
        value
      else
        value
      end
    end
  end
end
