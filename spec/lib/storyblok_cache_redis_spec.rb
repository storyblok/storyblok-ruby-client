require 'redis'
require_relative '../../lib/storyblok/cache/redis'
require 'spec_helper'

describe Storyblok::Cache::Redis, redis_cache: true do
  let(:redis_client) {
    raise StandardError, "Environment variable 'REDIS_URL' is not defined" if ENV['REDIS_URL'].nil?
    Redis.new(url: ENV['REDIS_URL'])
  }

  context "When '::Redis' from redis-rb gem is not available" do
    let!(:redis_constant_copy) { ::Redis }
    before { Object.send(:remove_const, :Redis) }
    after  { ::Redis = redis_constant_copy }
    it "raises Redis.current could not be found" do
      expect{ subject }.to raise_error(RuntimeError, 'Redis.current could not be found. Supply :redis option or make sure Redis.current is available.')
    end
  end

  context "When Storyblok::Cache::Redis is initialized without 'redis' arg" do
    it "asks the redis to '::Redis.current'" do
      redis_current = nil
      expect{ redis_current = subject.redis }.not_to raise_error
      expect(redis_current.object_id).to eq(::Redis.current.object_id)
    end
  end

  describe "#cache" do
    before { redis_client.keys("storyblok:*").each { |e| redis_client.del(e) } }

    let(:key) { "storyblok:my_cache_key" }
    context "When is passed an block" do
      context "When the result it's not cached" do
        it "caches the block result and returns the block call result" do
          expect{
            subject.cache(key){ "my_value" }
          }.to change { redis_client.keys("#{key}*").size }.from(0).to(1)

          expect(redis_client.get(key)).to eq("my_value")
        end
      end

      context "When the arg expire as '0' is passed" do
        let(:expire) { 0 }
        it "returns the result of the block" do
          expect(subject.cache(key, expire){ "my_value" } ).to eq("my_value")
        end

        it "doesn't cache anything" do
          expect{ subject.cache(key, expire){ "my_value" } }.not_to change { redis_client.keys.size }
        end
      end

      context "When the key has value on cache" do
        before { subject.cache(key){ "my_value_cached" } }
        it "the block it's no called and the cache stays untouched and the cached value is returned" do
          expect{
            subject.cache(key){ "my_new_value" }
          }.not_to change { redis_client.keys("#{key}*").size }

          expect(redis_client.get(key)).to eq("my_value_cached")
        end
      end
    end
  end

  describe "#set" do
    subject { super().set(key, value, expire) }
    before { redis_client.keys("storyblok:*").each { |e| redis_client.del(e) } }
    let(:key) {'storyblok:my_key'}
    let(:value) {'my_value'}

    context "When arg 'expire' is false" do
      let(:expire) { false }
      it "store the key value at Redis database WITHOUT expiration" do
        expect{ subject }.to change { redis_client.keys("#{key}*").size }.from(0).to(1)
        expect(redis_client.get(key)).to eq(value)
        expect(redis_client.ttl(key)).to eq(-1) # -1 means no expiration for redis key
      end
    end

    context "When args 'expire' is valid integer" do
      let(:expire) { 60 * 60 }
      it "store the key value at Redis database WITH expiration" do
        expect{ subject }.to change { redis_client.keys("#{key}*").size }.from(0).to(1)
        expect(redis_client.get(key)).to eq(value)
        expect(redis_client.ttl(key)).to be > 1
      end
    end
  end
end
