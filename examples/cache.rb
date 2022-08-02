# bundle exec ruby examples/cache.rb

require "storyblok"
require "redis"

logger = Logger.new(STDOUT)

redis_url = "redis://localhost:6379"
Storyblok::Cache.client = Redis.new(:url => redis_url)

client = Storyblok::Client.new(
  token: "t618GfLe1YHICBioAHnMrwtt",
  api_url: "localhost:3001",
  secure: false,
  logger: logger
)

links = client.links
links = client.links
links = client.flush
links = client.links
