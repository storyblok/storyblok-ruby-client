require_relative '../../lib/storyblok/client'
require_relative '../../lib/storyblok/cache/redis'
require 'redis'
require 'spec_helper'

describe Storyblok::Client do
  subject { described_class.new(token: token, version: version) }

  context "When querying CDN Content" do

    context "With token defined" do
      let(:token) { '<SPACE_PUBLIC_TOKEN>' }

      context "When querying stories" do

        context "When querying the published version" do
          let(:version) { 'published' }

          context "when querying an existent story by slug" do
            it "returns a story", :vcr do
              expect(subject.story('simple_content')['data']).to eq({
                "story"=> {
                  "name"=>"simple_content",
                  "created_at"=>"2020-08-20T18:01:55.065Z",
                  "published_at"=>"2020-08-20T18:13:34.946Z",
                  "alternates"=>[],
                  "id"=>18409805,
                  "uuid"=>"fe520269-b092-482c-94c4-8028eb81af41",
                  "content"=> {
                      "_uid"=>"ae111a76-84b7-43cc-a6a0-77a70de1b6f4",
                      "component"=>"SimpleTextContentType",
                      "SimpleText"=>"Simple Content from a Simple Text PUBLISHED"
                    },
                  "slug"=>"simple_content",
                  "full_slug"=>"simple_content",
                  "default_full_slug"=>nil,
                  "sort_by_date"=>nil,
                  "position"=>0,
                  "tag_list"=>[],
                  "is_startpage"=>false,
                  "parent_id"=>0,
                  "meta_data"=>nil,
                  "group_id"=>"f905f0f0-569e-4036-bcef-1479e5088956",
                  "first_published_at"=>"2020-08-20T18:03:33.759Z",
                  "release_id"=>nil,
                  "lang"=>"default",
                  "path"=>nil,
                  "translated_slugs"=>[]
                }
              })
            end
          end

          context "when querying an story list by slug" do
            it "returns a stories list", :vcr do
              expect(subject.stories(starts_with: 'my-folder-slug')['data']).to eq(
                {
                  "stories"=>[
                    {
                      "name"=>"simple_content_2",
                      "created_at"=>"2020-08-20T18:48:44.026Z",
                      "published_at"=>"2020-08-20T18:48:59.352Z",
                      "alternates"=>[],
                      "id"=>18409847,
                      "uuid"=>"4b069560-749d-4f2b-8304-97a2a465fb49",
                      "content"=>{
                        "_uid"=>"ad08db76-4465-4539-880b-6437629d66ff",
                         "component"=>"SimpleTextContentType",
                         "SimpleText"=>"Simple Content Published"
                      },
                      "slug"=>"simple_content_2",
                      "full_slug"=>"my-folder-slug/simple_content_2",
                      "default_full_slug"=>nil,
                      "sort_by_date"=>nil,
                      "position"=>-10,
                      "tag_list"=>["my another tag", "my first tag"],
                      "is_startpage"=>false,
                      "parent_id"=>18409844,
                      "meta_data"=>nil,
                      "group_id"=>"0d452376-8b44-4ed6-b9e5-65965adbf0ff",
                      "first_published_at"=>"2020-08-20T18:48:59.000Z",
                      "release_id"=>nil,
                      "lang"=>"default",
                      "path"=>nil,
                      "translated_slugs"=>[]
                    },
                    {
                      "name"=>"simple_content_1",
                      "created_at"=>"2020-08-20T18:45:52.758Z",
                      "published_at"=>"2020-08-20T18:46:48.719Z",
                      "alternates"=>[],
                      "id"=>18409845,
                      "uuid"=>"542e19cc-ff06-4f19-ae64-a725c89e3406",
                      "content"=>{
                        "_uid"=>"e8ac85a4-91eb-42c2-8a18-b6e709b67e9d",
                        "component"=>"SimpleTextContentType",
                        "SimpleText"=>"Simple Content Published"},
                      "slug"=>"simple_content_1",
                      "full_slug"=>"my-folder-slug/simple_content_1",
                      "default_full_slug"=>nil,
                      "sort_by_date"=>nil,
                      "position"=>0,
                      "tag_list"=>[],
                      "is_startpage"=>false,
                      "parent_id"=>18409844,
                      "meta_data"=>nil,
                      "group_id"=>"943ee7f6-b002-44c6-8e26-41b21b6792ea",
                      "first_published_at"=>"2020-08-20T18:46:39.840Z",
                      "release_id"=>nil,
                      "lang"=>"default",
                      "path"=>nil,
                      "translated_slugs"=>[]
                    }
                  ]
                }
              )
            end
          end
        end

        context "When querying the draft version" do
          subject { described_class.new(token: token) }

          let(:token) { '<SPACE_PREVIEW_TOKEN>' }

          context "when querying an existent story by slug" do
            it "returns a story", :vcr do
              expect(subject.story('simple_content')['data']).to eq({
                "story" => {
                  "alternates"=>[],
                  "content"=>{
                    "SimpleText"=>"Simple Content from a Simple Text DRAFT VERSION",
                    "_editable"=>"<!--#storyblok\#{\"name\": \"SimpleTextContentType\", \"space\": \"91322\", \"uid\": \"ae111a76-84b7-43cc-a6a0-77a70de1b6f4\", \"id\": \"18409805\"}-->",
                    "_uid"=>"ae111a76-84b7-43cc-a6a0-77a70de1b6f4",
                    "component"=>"SimpleTextContentType"
                  },
                  "created_at"=>"2020-08-20T18:01:55.065Z",
                  "default_full_slug"=>nil,
                  "first_published_at"=>"2020-08-20T18:03:33.759Z",
                  "full_slug"=>"simple_content",
                  "group_id"=>"f905f0f0-569e-4036-bcef-1479e5088956",
                  "id"=>18409805,
                  "is_startpage"=>false,
                  "lang"=>"default",
                  "meta_data"=>nil,
                  "name"=>"simple_content",
                  "parent_id"=>0,
                  "path"=>nil,
                  "position"=>0,
                  "published_at"=>"2020-08-20T18:13:34.946Z",
                  "release_id"=>nil,
                  "slug"=>"simple_content",
                  "sort_by_date"=>nil,
                  "tag_list"=>[],
                  "translated_slugs"=>[],
                  "uuid"=>"fe520269-b092-482c-94c4-8028eb81af41"
                }
              })
            end
          end

          context "when querying an story list by slug" do
            it "returns a stories list", :vcr do
              expect(subject.stories(starts_with: 'my-folder-slug')['data']).to eq(
                {
                  "stories"=> [
                    {
                      "name"=>"simple_content_2",
                      "created_at"=>"2020-08-20T18:48:44.026Z",
                      "published_at"=>"2020-08-20T18:48:59.352Z",
                      "alternates"=>[],
                      "id"=>18409847,
                      "uuid"=>"4b069560-749d-4f2b-8304-97a2a465fb49",
                      "content"=> {
                        "_uid"=>"ad08db76-4465-4539-880b-6437629d66ff",
                        "component"=>"SimpleTextContentType",
                        "SimpleText"=>"Simple Content Draft",
                        "_editable"=>"<!--#storyblok\#{\"name\": \"SimpleTextContentType\", \"space\": \"91322\", \"uid\": \"ad08db76-4465-4539-880b-6437629d66ff\", \"id\": \"18409847\"}-->"
                      },
                      "slug"=>"simple_content_2",
                      "full_slug"=>"my-folder-slug/simple_content_2",
                      "default_full_slug"=>nil,
                      "sort_by_date"=>nil,
                      "position"=>-10,
                      "tag_list"=>["my another tag", "my first tag"],
                      "is_startpage"=>false,
                      "parent_id"=>18409844,
                      "meta_data"=>nil,
                      "group_id"=>"0d452376-8b44-4ed6-b9e5-65965adbf0ff",
                      "first_published_at"=>"2020-08-20T18:48:59.000Z",
                      "release_id"=>nil,
                      "lang"=>"default",
                      "path"=>nil,
                      "translated_slugs"=>[]
                    },
                   {
                      "name"=>"simple_content_1",
                      "created_at"=>"2020-08-20T18:45:52.758Z",
                      "published_at"=>"2020-08-20T18:46:48.719Z",
                      "alternates"=>[],
                      "id"=>18409845,
                      "uuid"=>"542e19cc-ff06-4f19-ae64-a725c89e3406",
                      "content"=> {
                        "_uid"=>"e8ac85a4-91eb-42c2-8a18-b6e709b67e9d",
                        "component"=>"SimpleTextContentType",
                        "SimpleText"=>"Simple Content Draft",
                        "_editable"=>"<!--#storyblok\#{\"name\": \"SimpleTextContentType\", \"space\": \"91322\", \"uid\": \"e8ac85a4-91eb-42c2-8a18-b6e709b67e9d\", \"id\": \"18409845\"}-->"
                      },
                      "slug"=>"simple_content_1",
                      "full_slug"=>"my-folder-slug/simple_content_1",
                      "default_full_slug"=>nil,
                      "sort_by_date"=>nil,
                      "position"=>0,
                      "tag_list"=>[],
                      "is_startpage"=>false,
                      "parent_id"=>18409844,
                      "meta_data"=>nil,
                      "group_id"=>"943ee7f6-b002-44c6-8e26-41b21b6792ea",
                      "first_published_at"=>"2020-08-20T18:46:39.840Z",
                      "release_id"=>nil,
                      "lang"=>"default",
                      "path"=>nil,
                      "translated_slugs"=>[]
                    }
                  ]
                }
              )
            end
          end
        end
      end

      context "When querying datasources" do
        context "When querying the published version" do
          let(:version) { 'published' }
          it "returns a datasources list", :vcr do
            expect(subject.datasources['data']).to eq(
              {
                "datasources" => [
                  {
                    "dimensions"=>[],
                    "id"=>23537,
                    "name"=>"my_datasource",
                    "slug"=>"my-datasource-slug"
                  }
                ]
              }
            )
          end
        end
      end

      context "When querying datasource_entries" do
        context "When querying the published version" do
          let(:version) { 'published' }
          it "returns a datasource_entries list", :vcr do
            expect(subject.datasource_entries['data']).to eq(
              {
                "datasource_entries"=>[
                  {
                    "id"=>404023,
                    "name"=>"key_1",
                    "value"=>"value_1",
                    "dimension_value"=>nil
                  },
                  {
                    "id"=>404024,
                    "name"=>"key_2",
                    "value"=>"value_2",
                    "dimension_value"=>nil
                  }
                ]
              }
            )
          end
        end
      end

      context "When querying tags" do
        context "When querying the published version" do
          let(:version) { 'published' }
          it "get a tags list", :vcr do
            expect(subject.tags['data']).to eq(
              {
                "tags"=>[
                  {
                    "name"=>"my another tag",
                    "taggings_count"=>1
                  },
                  {
                    "name"=>"my first tag",
                    "taggings_count"=>1
                  }
                ]
              }
            )
          end
        end
      end

      context "When querying links" do
        context "When querying the published version" do
          let(:version) { 'published' }
          it "get a links list", :vcr do
            expect(subject.links['data']).to eq(
              {
                "links" => {
                  "4b069560-749d-4f2b-8304-97a2a465fb49"=>{
                    "id"=>18409847,
                    "is_folder"=>false,
                    "is_startpage"=>false,
                    "name"=>"simple_content_2",
                    "parent_id"=>18409844,
                    "position"=>-10,
                    "published"=>true,
                    "real_path"=>"/my-folder-slug/simple_content_2",
                    "slug"=>"my-folder-slug/simple_content_2",
                    "uuid"=>"4b069560-749d-4f2b-8304-97a2a465fb49"
                  },
                  "542e19cc-ff06-4f19-ae64-a725c89e3406"=>{
                    "id"=>18409845,
                    "is_folder"=>false,
                    "is_startpage"=>false,
                    "name"=>"simple_content_1",
                    "parent_id"=>18409844,
                    "position"=>0,
                    "published"=>true,
                    "real_path"=>"/my-folder-slug/simple_content_1",
                    "slug"=>"my-folder-slug/simple_content_1",
                    "uuid"=>"542e19cc-ff06-4f19-ae64-a725c89e3406"
                  },
                  "73330f5f-5dc9-4876-90c6-8ef0f21252a0"=>{
                    "id"=>18409844,
                    "is_folder"=>true,
                    "is_startpage"=>false,
                    "name"=>"my_folder_name",
                    "parent_id"=>0,
                    "position"=>-10,
                    "published"=>false,
                    "real_path"=>"/my-folder-slug",
                    "slug"=>"my-folder-slug",
                    "uuid"=>"73330f5f-5dc9-4876-90c6-8ef0f21252a0"
                  },
                  "fe520269-b092-482c-94c4-8028eb81af41"=>{
                    "id"=>18409805,
                    "is_folder"=>false,
                    "is_startpage"=>false,
                    "name"=>"simple_content",
                    "parent_id"=>0,
                    "position"=>0,
                    "published"=>true,
                    "real_path"=>"/simple_content",
                    "slug"=>"simple_content",
                    "uuid"=>"fe520269-b092-482c-94c4-8028eb81af41"
                  }
                }
              }
            )
          end
        end
      end

      context "When querying Space Info" do
        context "When querying the published version", :vcr do
          let(:version) { 'published' }
          it "get the space info" do
            expect(subject.space['data']).to eq(
              {
                "space"=>{
                  "id"=>91322,
                  "name"=>"My Cool Space",
                  "domain"=>"https://quickstart.me.storyblok.com/",
                  "version"=>1597954133,
                  "language_codes"=>[]
                }
              }
            )
          end
        end
      end

      context "When getting a content tree" do
        context "When querying the published version" do
          let(:version) { 'published' }
          it "get a content tree", :vcr  do
            expect(subject.tree).to eq(
              {
                18409844 =>
                 {
                   'item' =>
                     {
                       'id' => 18409844,
                       'slug' => 'my-folder-slug',
                       'name' => 'my_folder_name',
                       'is_folder' => true,
                       'parent_id' => 0,
                       'published' => false,
                       'position' => -10,
                       'uuid' => '73330f5f-5dc9-4876-90c6-8ef0f21252a0',
                       'is_startpage' => false,
                       'real_path' => '/my-folder-slug'
                     },
                   'children' =>
                         {
                           18409847 =>
                            {
                              'item' =>
                                 {
                                   'id' => 18409847,
                                   'slug' => 'my-folder-slug/simple_content_2',
                                   'name' => 'simple_content_2',
                                   'is_folder' => false,
                                   'parent_id' => 18409844,
                                   'published' => true,
                                   'position' => -10,
                                   'uuid' => '4b069560-749d-4f2b-8304-97a2a465fb49',
                                   'is_startpage' => false,
                                   'real_path' => '/my-folder-slug/simple_content_2'
                                 },
                              'children' => {}
                            },
                           18409845 =>
                   {
                     'item' =>
                        {
                          'id' => 18409845,
                          'slug' => 'my-folder-slug/simple_content_1',
                          'name' => 'simple_content_1',
                          'is_folder' => false,
                          'parent_id' => 18409844,
                          'published' => true,
                          'position' => 0,
                          'uuid' => '542e19cc-ff06-4f19-ae64-a725c89e3406',
                          'is_startpage' => false,
                          'real_path' => '/my-folder-slug/simple_content_1'
                        },
                     'children' => {}
                   }
                         }
                 },
                18409805 =>
              {
                'item' =>
                  {
                    'id' => 18409805,
                    'slug' => 'simple_content',
                    'name' => 'simple_content',
                    'is_folder' => false,
                    'parent_id' => 0,
                    'published' => true,
                    'position' => 0,
                    'uuid' => 'fe520269-b092-482c-94c4-8028eb81af41',
                    'is_startpage' => false,
                    'real_path' => '/simple_content'
                  },
                'children' => {}
              }
              }
            )
          end
        end
      end

      describe "#get_from_cdn" do
        let(:version) { 'published' }
        it "get a tags list", :vcr do
          expect(subject.get_from_cdn('tags')['data']).to eq(
              {
                "tags"=>[
                  {
                    "name"=>"my another tag",
                    "taggings_count"=>1
                  },
                  {
                    "name"=>"my first tag",
                    "taggings_count"=>1
                  }
                ]
              }
            )
        end
      end

      context "When the RestClient::TooManyRequests is raised" do # YOUR API CALL LIMIT HAS BEEN REACHED
        subject { super().tags }

        let(:version) { 'published' }
        it "auto retry the request for 3 times before raise error" do
          # This cassette was manually edited to allow test this scenario
          VCR.use_cassette('Storyblok_Client/When_querying_CDN_Content/With_token_defined/When_the_RestClient_TooManyRequests_is_raised/auto_retry_the_request_for_3_times_before_raise_error') do
            expect(subject['data']).to eq(
              {
                "tags"=>[
                  {
                    "name"=>"my another tag",
                    "taggings_count"=>1
                  },
                  {
                    "name"=>"my first tag",
                    "taggings_count"=>1
                  }
                ]
              }
            )
          end
        end

        it "raises an error after the 3 retry" do
          # This cassette was manually edited to allow test this scenario
          VCR.use_cassette('Storyblok_Client/When_querying_CDN_Content/With_token_defined/When_the_RestClient_TooManyRequests_is_raised/raises an error after the 3 retry') do
            expect{ subject['data'] }.to raise_error(RestClient::TooManyRequests)
          end
        end
      end

      context "When using a renderer" do
        let(:token) { '<SPACE_PUBLIC_TOKEN>' }
        let(:version) { 'published' }

        let(:data) {
          {
            'type' => 'doc',
            'content' => [
              {
                'type' => 'paragraph',
                'content' => [ {'text' => 'Good', 'type' => 'text'}]
              },
              {
                'type' => 'blok',
                'attrs' => { 'body' => [{'component' => 'button', 'text' => 'Click me'}] }
              }
            ]
          }
        }

        context "When setting a renderer at client initialization" do
          subject { described_class.new(token: token, version: version, component_resolver: component_resolver) }
          let(:component_resolver) { ->(component, data) { "Placeholder for #{component}: #{data['text']}" } }

          it "returns data rendered with component_resolver" do
            expect(subject.render(data)).to eq("<p>Good</p>Placeholder for button: Click me")
          end
        end

        context "When setting a renderer after client initialization" do
          subject { described_class.new(token: token, version: version) }
          let(:component_resolver) { ->(component, data) { "Placeholder for #{component}: #{data['text']}" } }

          it "set renderer and returns data rendered with component_resolver" do
            subject.set_component_resolver(component_resolver)
            expect(subject.render(data)).to eq("<p>Good</p>Placeholder for button: Click me")
          end
        end
      end

      context "When caching is enabled", redis_cache: true do
        subject { described_class.new(token: token, version: version, cache: cache) }
        before { redis_client.keys("storyblok:*").each { |e| redis_client.del(e) } }
        let(:redis_client) {
          raise StandardError, "Environment variable 'REDIS_URL' is not defined" if ENV['REDIS_URL'].nil?
          Redis.new(url: ENV['REDIS_URL'])
        }

        let(:cache) { Storyblok::Cache::Redis.new(redis: redis_client) }
        let(:token) { '<SPACE_PUBLIC_TOKEN>' }
        let(:version) { 'published' }
        let(:tags_response_expected) { {
          "tags"=>[
            {
              "name"=>"my another tag",
              "taggings_count"=>1
            },
            {
              "name"=>"my first tag",
              "taggings_count"=>1
            }
          ]
        } }
        it "caches the tags list", :vcr do
          expect{ subject.tags }.to change{ redis_client.keys("storyblok:*").size }.from(0).to(2) # stores cache and cache_version

          expect(subject.tags['data']).to eq(tags_response_expected)
          response_cached = redis_client.get(redis_client.keys("storyblok:*").first)
          expect(JSON.parse(response_cached)['data']).to eq(tags_response_expected)
        end

        it "flushes the cache", :vcr do
          subject.tags # caches a request
          expect { subject.flush }.to change { redis_client.get("storyblok:<SPACE_PUBLIC_TOKEN>:version") }.from('0') # generates the next_cache_version
          next_cache_version = redis_client.get("storyblok:<SPACE_PUBLIC_TOKEN>:version")
          next_cache_key_partial = "storyblok:<SPACE_PUBLIC_TOKEN>:v:#{next_cache_version}*"
          expect { subject.tags }.to change { redis_client.keys(next_cache_key_partial).size }.from(0).to(1) # generates the cache using the next_cache_version generated by flush
          expect(subject.tags['data']).to eq(tags_response_expected) # check if response ex correct
          response_cached = redis_client.get(redis_client.keys(next_cache_key_partial).first)
          expect(JSON.parse(response_cached)['data']).to eq(tags_response_expected) # check if the response was correctly cached
        end
      end
    end
  end

  context "When Managing the Space" do
    context "With oauth_token defined" do
      let(:oauth_token) { '<MY_PERSONAL_ACCESS_TOKEN>' }
      subject { described_class.new(oauth_token: oauth_token) }

      context "When performing a GET request" do
        context "Listing spaces" do
          subject { super().get('spaces') }

          it "returns a space list", :vcr do
            expect(subject['data']).to eq({
              "spaces"=> [
                { "name"=>"Clean Space",     "id"=>91322, "euid"=>nil, "owner_id"=>"<OWNER_ID_INTEGER>" },
                { "name"=>"blog_space",      "id"=>91112, "euid"=>nil, "owner_id"=>"<OWNER_ID_INTEGER>" },
                { "name"=>"My beta Space",   "id"=>88422, "euid"=>"",  "owner_id"=>"<OWNER_ID_INTEGER>" },
                { "name"=>"My new Space",    "id"=>86092, "euid"=>nil, "owner_id"=>"<OWNER_ID_INTEGER>" },
                { "name"=>"Your demo space", "id"=>85563, "euid"=>nil, "owner_id"=>"<OWNER_ID_INTEGER>" }
              ]
            })
          end
        end
      end

      context "When performing a POST request" do
        context "Creating a story" do
          subject { super().post("spaces/#{space_id}/stories", story_params) }
          let(:space_id) { 91322 }
          let(:story_params) { { story: { name: 'my awesome new story', slug: 'my-awesome-new-story' } } }

          it "creates a story", :vcr do
            expect(subject['headers'][:status]).to eq("201 Created")
            expect(subject['data']).to eq({
              "story"=>{
                "name"=>"my awesome new story",
                "parent_id"=>0,
                "group_id"=>"7a015f0b-1585-4e17-8f32-adf2755087bb",
                "alternates"=>[],
                "created_at"=>"2020-08-25T16:23:38.022Z",
                "sort_by_date"=>nil,
                "tag_list"=>[],
                "updated_at"=>"2020-08-25T16:23:38.022Z",
                "published_at"=>nil,
                "id"=>18670449,
                "uuid"=>"defee8f9-0704-4855-aebc-6d37908297ea",
                "is_folder"=>false,
                "content"=>{"component"=>"root", "body"=>[], "_uid"=>"fa221d61-73ba-4435-82a9-26ac1cf4bf11"},
                "published"=>false,
                "slug"=>"my-awesome-new-story",
                "path"=>nil,
                "full_slug"=>"my-awesome-new-story",
                "default_root"=>nil,
                "disble_fe_editor"=>false,
                "parent"=>nil,
                "is_startpage"=>false,
                "unpublished_changes"=>false,
                "meta_data"=>nil,
                "imported_at"=>nil,
                "preview_token"=>{"token"=>"<PREVIEW_TOKEN>", "timestamp"=>"1598372618"},
                "pinned"=>false,
                "breadcrumbs"=>[],
                "publish_at"=>nil,
                "expire_at"=>nil,
                "first_published_at"=>nil,
                "last_author"=>{"id"=>"<OWNER_ID_INTEGER>", "userid"=>"<MY_USER_EMAIL>", "friendly_name"=>"<MY_USER_EMAIL>"},
                "user_ids"=>[],
                "space_role_ids"=>[],
                "translated_slugs"=>[],
                "localized_paths"=>[],
                "position"=>-20,
                "translated_stories"=>[],
                "can_not_view"=>nil
              }
            })
          end
        end
      end

      context "When performing a PUT request" do
        context "Updating a story" do
          subject { super().put("spaces/#{space_id}/stories/#{story_id}", story_params) }
          let(:space_id) { 91322 }
          let(:story_id) { 18670449 }
          let(:story_params) { { story: { name: 'my awesome updated story' } } }

          it "updates a story", :vcr do
            expect(subject['headers'][:status]).to eq("200 OK")
            expect(subject['data']).to eq({
              "story"=>{
                "name"=>"my awesome updated story",
                "parent_id"=>0,
                "group_id"=>"7a015f0b-1585-4e17-8f32-adf2755087bb",
                "alternates"=>[],
                "created_at"=>"2020-08-25T16:23:38.022Z",
                "sort_by_date"=>nil,
                "tag_list"=>[],
                "updated_at"=>"2020-08-25T18:03:04.115Z",
                "published_at"=>nil,
                "id"=>18670449,
                "uuid"=>"defee8f9-0704-4855-aebc-6d37908297ea",
                "is_folder"=>false,
                "content"=>{"_uid"=>"fa221d61-73ba-4435-82a9-26ac1cf4bf11", "body"=>[], "component"=>"root"},
                "published"=>false,
                "slug"=>"my-awesome-new-story",
                "path"=>nil,
                "full_slug"=>"my-awesome-new-story",
                "default_root"=>nil,
                "disble_fe_editor"=>false,
                "parent"=>nil,
                "is_startpage"=>false,
                "unpublished_changes"=>true,
                "meta_data"=>nil,
                "imported_at"=>nil,
                "preview_token"=>{"token"=>"d5681a1d0e5d798582a0e6ed791c6bfa1f618e54", "timestamp"=>"1598378584"},
                "pinned"=>false,
                "breadcrumbs"=>[],
                "publish_at"=>nil,
                "expire_at"=>nil,
                "first_published_at"=>nil,
                "last_author"=>{"id"=>"<OWNER_ID_INTEGER>", "userid"=>"<MY_USER_EMAIL>", "friendly_name"=>"<MY_USER_EMAIL>"},
                "user_ids"=>[],
                "space_role_ids"=>[],
                "translated_slugs"=>[],
                "localized_paths"=>[],
                "position"=>-20,
                "translated_stories"=>[],
                "can_not_view"=>nil
              }
            })
          end
        end
      end

      context "When performing a DELETE request" do
        context "deleting a story" do
          subject { super().delete("spaces/#{space_id}/stories/#{story_id}") }
          let(:space_id) { 91322 }
          let(:story_id) { 18670449 }
          it "deletes a story", :vcr do
            expect(subject['headers'][:status]).to eq("200 OK")
            expect(subject['data']).to eq({
              "story"=> {
                "name"=>"my awesome updated story",
                "parent_id"=>0,
                "group_id"=>"7a015f0b-1585-4e17-8f32-adf2755087bb",
                "alternates"=>[],
                "created_at"=>"2020-08-25T16:23:38.022Z",
                "sort_by_date"=>nil,
                "tag_list"=>[],
                "updated_at"=>"2020-08-25T18:03:04.115Z",
                "published_at"=>nil,
                "id"=>18670449,
                "uuid"=>"defee8f9-0704-4855-aebc-6d37908297ea",
                "is_folder"=>false,
                "content"=>{"_uid"=>"fa221d61-73ba-4435-82a9-26ac1cf4bf11", "body"=>[], "component"=>"root"},
                "published"=>false,
                "slug"=>"my-awesome-new-story",
                "path"=>nil,
                "full_slug"=>"my-awesome-new-story",
                "default_root"=>nil,
                "disble_fe_editor"=>false,
                "parent"=>nil,
                "is_startpage"=>false,
                "unpublished_changes"=>true,
                "meta_data"=>nil,
                "imported_at"=>nil,
                "preview_token"=>{"token"=>"af676cb58efa328b9f6c30251b9212598c66d55b", "timestamp"=>"1598378897"},
                "pinned"=>false,
                "breadcrumbs"=>[],
                "publish_at"=>nil,
                "expire_at"=>nil,
                "first_published_at"=>nil,
                "last_author"=>{"id"=>"<OWNER_ID_INTEGER>", "userid"=>"<MY_USER_EMAIL>", "friendly_name"=>"<MY_USER_EMAIL>"},
                "user_ids"=>[],
                "space_role_ids"=>[],
                "translated_slugs"=>[],
                "localized_paths"=>[],
                "position"=>-20,
                "translated_stories"=>[],
                "can_not_view"=>nil
              }
            })
          end
        end
      end

      context "When the RestClient::TooManyRequests is raised" do # YOUR API CALL LIMIT HAS BEEN REACHED
        subject { super().get('spaces') }
        it "auto retry the request for 3 times before raise error" do
          # This cassette was manually edited to allow test this scenario
          VCR.use_cassette('Storyblok_Client/When_Managing_the_Space/With_oauth_token_defined/When_the_RestClient_TooManyRequests_is_raised/auto_retry_the_request_for_3_times_before_raise_error') do
            expect(subject['data']).to eq({
              "spaces"=> [
                { "name"=>"Clean Space",     "id"=>91322, "euid"=>nil, "owner_id"=>"<OWNER_ID_INTEGER>" },
                { "name"=>"blog_space",      "id"=>91112, "euid"=>nil, "owner_id"=>"<OWNER_ID_INTEGER>" },
                { "name"=>"My beta Space",   "id"=>88422, "euid"=>"",  "owner_id"=>"<OWNER_ID_INTEGER>" },
                { "name"=>"My new Space",    "id"=>86092, "euid"=>nil, "owner_id"=>"<OWNER_ID_INTEGER>" },
                { "name"=>"Your demo space", "id"=>85563, "euid"=>nil, "owner_id"=>"<OWNER_ID_INTEGER>" }
              ]
            })
          end
        end

        it "raises an error after the 3 retry" do
          # This cassette was manually edited to allow test this scenario
          VCR.use_cassette('Storyblok_Client/When_Managing_the_Space/With_oauth_token_defined/When_the_RestClient_TooManyRequests_is_raised/raises an error after the 3 retry') do
            expect{ subject['data'] }.to raise_error(RestClient::TooManyRequests)
          end
        end
      end
    end
  end
end
