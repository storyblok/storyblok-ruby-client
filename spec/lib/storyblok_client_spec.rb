require_relative '../../lib/storyblok/client'
require_relative '../../lib/storyblok/cache/redis'
require 'redis'
require 'spec_helper'

describe Storyblok::Client do
  subject { described_class.new(params) }

  context "When querying CDN Content" do
    context "With token defined" do
      context "When querying stories" do
        context "When querying the published version" do
          let(:params) { {token: '<SPACE_PUBLIC_TOKEN>', version: 'published'} }
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
          let(:params) { {token: '<SPACE_PREVIEW_TOKEN>'} }

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
          let(:params) { {token: '<SPACE_PUBLIC_TOKEN>', version: 'published'} }
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
          let(:params) { {token: '<SPACE_PUBLIC_TOKEN>', version: 'published'} }
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
          let(:params) { {token: '<SPACE_PUBLIC_TOKEN>', version: 'published'} }
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
          let(:params) { {token: '<SPACE_PUBLIC_TOKEN>', version: 'published'} }
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
          let(:params) { {token: '<SPACE_PUBLIC_TOKEN>', version: 'published'} }
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
          let(:params) { {token: '<SPACE_PUBLIC_TOKEN>', version: 'published'} }
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

      context "When caching is enabled", redis_cache: true do
        before { redis_client.keys("storyblok:*").each { |e| redis_client.del(e) } }
        let(:redis_client) {
          raise StandardError, "Environment variable 'REDIS_URL' is not defined" if ENV['REDIS_URL'].nil?
          Redis.new(url: ENV['REDIS_URL'])
        }

        let(:params) {
          cache = Storyblok::Cache::Redis.new(redis: redis_client)
          { token: '<SPACE_PUBLIC_TOKEN>', version: 'published', cache: cache }
        }

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
          expect{ subject.tags }.to change{ redis_client.keys("storyblok:*").size }.from(0).to(1)

          expect(subject.tags['data']).to eq(tags_response_expected)
          response_cached = redis_client.get(redis_client.keys("storyblok:*").first)
          expect(JSON.parse(response_cached)['data']).to eq(tags_response_expected)
        end

        it "flushes the cache", :vcr do
          subject.tags # caches a request
          expect { subject.flush }.to change { redis_client.keys.size }.by(1) # generates the next_cache_version
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
end
