<div align="center">
	<a  href="https://www.storyblok.com?utm_source=github.com&utm_medium=readme&utm_campaign=storyblok-ruby"  align="center">
		<img  src="https://a.storyblok.com/f/88751/1776x360/95e296dafa/sb-ruby.png"  alt="Storyblok Logo">
	</a>
	<h1 align="center">Storyblok Ruby Client</h1>
	<p align="center">This is the official <a href="http://www.storyblok.com?utm_source=github.com&utm_medium=readme&utm_campaign=storyblok-ruby" target="_blank">Storyblok</a> ruby client for easy access of the management and content delivery api.</p>
</div>

<p align="center">
  <a href="https://codeclimate.com/github/storyblok/storyblok-ruby/test_coverage">
    <img src="https://api.codeclimate.com/v1/badges/76e7fcc8524d4fadeeee/test_coverage" alt="Test Coverage" />
  </a>
  <a href="https://discord.gg/jKrbAMz">
   <img src="https://img.shields.io/discord/700316478792138842?label=Join%20Our%20Discord%20Community&style=appveyor&logo=discord&color=09b3af">
   </a>
  <a href="https://twitter.com/intent/follow?screen_name=storyblok">
    <img src="https://img.shields.io/badge/Follow-%40storyblok-09b3af?style=appveyor&logo=twitter" alt="Follow @Storyblok" />
  </a><br/>
  <a href="https://app.storyblok.com/#!/signup?utm_source=github.com&utm_medium=readme&utm_campaign=storyblok-ruby">
    <img src="https://img.shields.io/badge/Try%20Storyblok-Free-09b3af?style=appveyor&logo=data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAB4AAAAeCAYAAAA7MK6iAAAABGdBTUEAALGPC/xhBQAAADhlWElmTU0AKgAAAAgAAYdpAAQAAAABAAAAGgAAAAAAAqACAAQAAAABAAAAHqADAAQAAAABAAAAHgAAAADpiRU/AAACRElEQVRIDWNgGGmAEd3D3Js3LPrP8D8WXZwSPiMjw6qvPoHhyGYwIXNAbGpbCjbzP0MYuj0YFqMroBV/wCxmIeSju64eDNzMBJUxvP/9i2Hnq5cM1devMnz984eQsQwETeRhYWHgIcJiXqC6VHlFBjUeXgav40cIWkz1oLYXFmGwFBImaDFBHyObcOzdW4aSq5eRhRiE2dgYlpuYoYSKJi8vw3GgWnyAJIs/AuPu4scPGObd/fqVQZ+PHy7+6udPOBsXgySLDfn5GRYYmaKYJcXBgWLpsx8/GPa8foWiBhuHJIsl2DkYQqWksZkDFgP5PObcKYYff//iVAOTIDlx/QPqRMb/YSYBaWlOToZIaVkGZmAZSQiQ5OPtwHwacuo4iplMQEu6tXUZMhSUGDiYmBjylFQYvv/7x9B04xqKOnQOyT5GN+Df//8M59ASXKyMHLoyDD5JPtbj42OYrm+EYgg70JfuYuIoYmLs7AwMjIzA+uY/zjAnyWJpDk6GOFnCvrn86SOwmsNtKciVFAc1ileBHFDC67lzG10Yg0+SjzF0ownsf/OaofvOLYaDQJoQIGix94ljv1gIZI8Pv38zPvj2lQWYf3HGKbpDCFp85v07NnRN1OBTPY6JdRSGxcCw2k6sZuLVMZ5AV4s1TozPnGGFKbz+/PE7IJsHmC//MDMyhXBw8e6FyRFLv3Z0/IKuFqvFyIqAzd1PwBzJw8jAGPfVx38JshwlbIygxmYY43/GQmpais0ODDHuzevLMARHBcgIAQAbOJHZW0/EyQAAAABJRU5ErkJggg==" alt="Follow @Storyblok" />
  </a>
</p>

## 🚀 Usage

### Install

```bash
gem 'storyblok'
```

### Usage for the content delivery api

By default the client loads the "draft" version of the Story. Be sure to set the version to "published" to get the published content only.

```ruby
# The draft mode is required for the preview
Storyblok::Client.new(version: 'draft')

# Requests only published stories
Storyblok::Client.new(version: 'published')
```

#### Using the APIs on other regions

You should use the space access token AND `api_region: 'us'` whenever your space was created under `US` Server Location.

```ruby
client = Storyblok::Client.new(token: 'YOUR_TOKEN', api_region: 'us')
```

#### Load a story

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

#### Load a list of stories

```ruby
# Get all Stories that start with news
client.stories({
  :starts_with => 'news'
})
```

#### Load a list of datasource entries

```ruby
# Get all label datasource entries
client.datasource_entries({
  :datasource => 'labels'
})

```

#### Load a list of tags

```ruby
# Get all Tags that within the folder news
client.tags({
  :starts_with => 'news'
})

```

#### Load a list of links

```ruby
client.links
```

### Generate a navigation tree

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

#### Get the space info

```ruby
client.space
```

### How to flush the cache

Following an example of how to flush the client cache:

```ruby
cache = Storyblok::Cache::Redis.new(redis: Redis.current)
client = Storyblok::Client.new(cache: cache, token: 'YOUR_TOKEN')

# Get a story and cache it
client.story('home')

# Flush the cache
client.flush
```

### Usage for the management api

#### Initialize the client and load spaces

```ruby
client = Storyblok::Client.new(oauth_token: 'YOUR_OAUTH_TOKEN')

# Get your spaces
client.get('spaces/')
```

#### Create a story

```ruby
client.post("spaces/{space_id}/stories", {story: {name: 'new', slug: "new"}})
```

#### Update a story

```ruby
client.put("spaces/{space_id}/stories/{story_id}", {story: {name: 'new', slug: "new"}})
```

#### Delete a story

```ruby
client.delete("spaces/{space_id}/stories/{story_id}")
```

### Rendering of richtext fields

This SDK comes with a rendering service for richtext fields of Storyblok to get html output.

#### Rendering a richtext field

```ruby
client.render(data.richtext_field)
```

#### Define a component renderer

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

#### Contribute

How to build a gem file.

~~~
gem build storyblok.gemspec
gem push storyblok-2.0.X.gem
~~~

#### Running Tests
We use [RSpec](http://rspec.info/) for testing.

###### To run the whole test suite you will need export the environment variables, ATTENTION when running the test suit with the variable `REDIS_URL` exported, the test suite will remove the keys with this pattern `storyblok:*` from the redis database defined by `REDIS_URL`

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

## 🔗 Related Links

* **[Storyblok & Ruby on GitHub](https://github.com/search?q=org%3Astoryblok+topic%3Aruby)**: Check all of our Ruby open source repos;
* **[Storyblok & Ruby 5 minutes tutorial](https://www.storyblok.com/tp/ruby-on-rails-cms?utm_source=github.com&utm_medium=readme&utm_campaign=storyblok-ruby)**: will show you how you can use the API-based CMS Storyblok in combination with the Framework “Ruby on Rails”;
* **[Technology Hub](https://www.storyblok.com/technologies?utm_source=github.com&utm_medium=readme&utm_campaign=storyblok-ruby)**: We prepared technology hubs so that you can find selected beginner tutorials, videos, boilerplates, and even cheatsheets all in one place;
* **[Storyblok CLI](https://github.com/storyblok/storyblok)**: A simple CLI for scaffolding Storyblok projects and fieldtypes.

## ℹ️ More Resources

### Support

* Bugs or Feature Requests? [Submit an issue](../../../issues/new);

* Do you have questions about Storyblok or you need help? [Join our Discord Community](https://discord.gg/jKrbAMz).

### Contributing

Please see our [contributing guidelines](https://github.com/storyblok/.github/blob/master/contributing.md) and our [code of conduct](https://www.storyblok.com/trust-center#code-of-conduct?utm_source=github.com&utm_medium=readme&utm_campaign=storyblok-ruby).
This project use [semantic-release](https://semantic-release.gitbook.io/semantic-release/) for generate new versions by using commit messages and we use the Angular Convention to naming the commits. Check [this question](https://semantic-release.gitbook.io/semantic-release/support/faq#how-can-i-change-the-type-of-commits-that-trigger-a-release) about it in semantic-release FAQ.
