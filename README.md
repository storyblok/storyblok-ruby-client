# About
This is the Storyblok ruby client for easy access of the content delivery api.

## Install

```bash
gem 'storyblok'
```

## Usage

### Load a Story

```ruby
client = new Storyblok::Client(token: 'YOUR_TOKEN')

# Optionally set a cache client
Storyblok::Cache.client = Redis.new(:url => 'redis://localhost:6379')

# Get a story
client.story('home')
```

### Load a list of Stories

```ruby
# Get all Stories that start with news
client.stories({
  :starts_with => 'news'
})
```

### Load a list of datasource entries

```ruby
# Get all label datasource entries
client.datasource_entries({
  :datasource => 'labels'
})

```

### Load a list of tags

```ruby
# Get all Tags that within the folder news
client.tags({
  :starts_with => 'news'
})

```

## Generate a navigation tree

```ruby
links = client.links
tree = links.as_tree

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
```

### License

This project is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)
