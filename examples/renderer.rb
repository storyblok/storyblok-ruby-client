# bundle exec ruby examples/renderer.rb

require_relative '../lib/storyblok'

logger = Logger.new(STDOUT)

client = Storyblok::Client.new(
  token: '6HMYdAjBoONyuS6GIf5PdAtt',
  logger: logger,
  component_resolver: ->(component, data) {
    "Placeholder for #{component}: #{data['text']}"
  }
)

puts client.render({'type' => 'doc', 'content' => [
  {'type' => 'paragraph', 'content' => [{'text' => 'Good', 'type' => 'text'}]},
  {'type' => 'blok', 'attrs' => {'body' => [{'component' => 'button', 'text' => 'Click me'}]}}
]})

res = client.story('article/article-1')

puts res['data']['story']['content']['intro']
puts client.render(res['data']['story']['content']['intro'])
