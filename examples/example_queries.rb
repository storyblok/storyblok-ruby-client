# bundle exec ruby examples/example_queries.rb

require 'storyblok'

logger = Logger.new(STDOUT)

client = Storyblok::Client.new(
  token: 't618GfLe1YHICBioAHnMrwtt',
  api_url: 'localhost:3001',
  secure: false,
  logger: logger
)

p client.stories(starts_with: 'en/news')
p client.story('demo1')
p client.datasource_entries(datasource: 'labels', per_page: 10)
p client.links
p client.datasources
