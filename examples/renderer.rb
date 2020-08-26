# bundle exec ruby examples/renderer.rb

require_relative '../lib/storyblok'
require 'redis'

logger = Logger.new(STDOUT)

redis = Redis.new(url: 'redis://localhost:6379')
cache = Storyblok::Cache::Redis.new(redis: redis)

client = Storyblok::Client.new(
  token: '6HMYdAjBoONyuS6GIf5PdAtt',
  logger: logger,
  component_resolver: ->(component, data) {
    "Placeholder for #{component}: #{data['text']}"
  },
  api_url: 'api-testing.storyblok.com',
  api_version: 2,
  cache: cache
)


res = client.flush
res = client.story('authors/page', {version: 'published'})
puts client.cache_version
res = client.story('authors/page', {version: 'published'})
res = client.story('authors/page', {version: 'published'})
res = client.story('authors/page', {version: 'published'})

puts res['data']
#puts client.render(res['data']['story']['content']['intro'])
