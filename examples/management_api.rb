# bundle exec ruby examples/management_api.rb

require 'storyblok'

logger = Logger.new(STDOUT)

client = Storyblok::Client.new(
  oauth_token: 'OAUTH_TOKEN',
  logger: logger,
  api_url: 'mapi.storyblok.com',
  api_version: 1
)

spaces = client.get('spaces')['data']['spaces']
space = spaces.first

p client.get("spaces/#{space['id']}")['data']['space']
story_res = client.post("spaces/#{space['id']}/stories", { story: { name: 'new', slug: "new" } })['data']

10.times do |index|
  client.get("spaces/#{space['id']}/stories/#{story_res['story']['id']}")
  puts index
end

p client.put("spaces/#{space['id']}/stories/#{story_res['story']['id']}", { story: { name: 'new123' } })['data']

10.times do |index|
  client.story('new')
  puts index
end

p client.delete("spaces/#{space['id']}/stories/#{story_res['story']['id']}")
