# bundle exec ruby examples/tree.rb

require 'storyblok'

logger = Logger.new(STDOUT)

client = Storyblok::Client.new(
  token: 't618GfLe1YHICBioAHnMrwtt',
  api_url: 'localhost:3001',
  secure: false,
  logger: logger
)

tree = client.tree

puts '<ul>'
tree.each do |key, item|
  puts '<li>' + item['item']['name']

  if !item['children'].empty?
    puts '<ul>'
    item['children'].each do |key, inner_item|
      puts '<li>' + inner_item['item']['name'] + '</li>'
    end
    puts '</ul>'
  end

  puts '</li>'
end
puts '</ul>'
