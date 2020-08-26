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

## Rendering of richtext fields

This SDK comes with a rendering service for richtext fields of Storyblok to get html output.

### Rendering a richtext field

```ruby
client.render(data.richtext_field)
```

### Define a component renderer

Storyblok's richtext field also let's you insert content blocks. To render these blocks you can define a Lambda.

```ruby
# Option 1: Define the resolver when initializing
client = Storyblok::Client.new(
  component_resolver: ->(component, data) {
    case component
    when 'button'
      "<button>#{data['text']}</button>"
    when 'your_custom_component'
      "<div class='welcome'>#{data['welcome_text']}</div>"
    end
  }
)

# Option 2: Define the resolver afterwards
client.set_component_resolver(->(component, data) {
  "#{component}"
})
```

### Contribute

How to build a gem file.

~~~
gem build storyblok.gemspec
gem push storyblok-2.0.X.gem
~~~

### Running Tests
We use [RSpec](http://rspec.info/) for testing.

#### To run the whole test suite you will need export the environment variables, ATTENTION when running the test suit with the variable `REDIS_URL` exported, the test suite will remove the keys with this pattern `storyblok:*` from the redis database defined by `REDIS_URL`

```bash
export REDIS_URL="redis://localhost:6379"
```

Optionally you can generate the test report coverage by setting the environment variable

```bash
export COVERAGE=true
```

To run the whole test suite use the following command:

```bash
rspec
```

To run tests without redis cache tests (for when you don't have redis, or to avoid the test suite to remove the keys with this pattern `storyblok:*` ):

```bash
rspec --tag ~redis_cache:true
```

### License

This project is open-sourced software licensed under the [MIT license](http://opensource.org/licenses/MIT)
