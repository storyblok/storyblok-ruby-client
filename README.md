# About
This is the Storyblok ruby client for easy access of the management and content delivery api.

## Install

```bash
gem 'storyblok'
```

## Usage for the content delivery api

By default the client loads the "draft" version of the Story. Be sure to set the version to "published" to get the published content only.

```ruby
# The draft mode is required for the preview
Storyblok::Client.new(version: 'draft')

# Requests only published stories
Storyblok::Client.new(version: 'published')
```

### Load a story

```ruby
# Without cache
client = Storyblok::Client.new(token: 'YOUR_TOKEN')

# Optionally set a cache client
redis = Redis.new(url: 'redis://localhost:6379')
cache = Storyblok::Cache::Redis.new(redis: redis)
client = Storyblok::Client.new(cache: cache, token: 'YOUR_TOKEN')

# Get a story
client.story('home')
```

### Load a list of stories

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

### Load a list of links

```ruby
client.links
```

## Generate a navigation tree

```ruby
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
```

### Get the space info

```ruby
client.space
```

## How to flush the cache

Following an example of how to flush the client cache:

```ruby
cache = Storyblok::Cache::Redis.new(redis: Redis.current)
client = Storyblok::Client.new(cache: cache, token: 'YOUR_TOKEN')

# Get a story and cache it
client.story('home')

# Flush the cache
client.flush
```

## Usage for the management api

### Initialize the client and load spaces

```ruby
client = Storyblok::Client.new(oauth_token: 'YOUR_OAUTH_TOKEN')

# Get your spaces
client.get('spaces')
```

### Create a story

```ruby
client.post("spaces/{space_id}/stories", {story: {name: 'new', slug: "new"}})
```

### Update a story

```ruby
client.put("spaces/{space_id}/stories/{story_id}", {story: {name: 'new', slug: "new"}})
```

### Delete a story

```ruby
client.delete("spaces/{space_id}/stories/{story_id}")
```


### License

This project is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)
