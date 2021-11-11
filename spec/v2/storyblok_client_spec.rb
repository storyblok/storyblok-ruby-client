require_relative '../../lib/storyblok/client'
require_relative '../../lib/storyblok/cache/redis'
require 'redis'
require 'spec_helper'

describe Storyblok::Client do
  subject { described_class.new(token: token, version: version) }

  context "V2" do
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
                    "name"=> "simple_content",
                    "created_at"=> "2020-08-20T18:01:55.065Z",
                    "published_at"=> "2021-11-11T20:16:01.847Z",
                    "id"=> 18409805,
                    "uuid"=> "fe520269-b092-482c-94c4-8028eb81af41",
                    "content"=> {
                      "_uid"=> "ae111a76-84b7-43cc-a6a0-77a70de1b6f4",
                      "component"=> "SimpleTextContentType",
                      "SimpleText"=> "Simple Content from a Simple Text PUBLISHED VERSION"
                    },
                    "slug"=> "simple_content",
                    "full_slug"=> "simple_content",
                    "sort_by_date"=> nil,
                    "position"=> 0,
                    "tag_list"=> [
                      "tag_out_of_any_folder"
                    ],
                    "is_startpage"=> false,
                    "parent_id"=> 0,
                    "meta_data"=> nil,
                    "group_id"=> "f905f0f0-569e-4036-bcef-1479e5088956",
                    "first_published_at"=> "2020-08-20T18:03:33.000Z",
                    "release_id"=> nil,
                    "lang"=> "default",
                    "path"=> nil,
                    "alternates"=> [],
                    "default_full_slug"=> nil,
                    "translated_slugs"=> nil
                  },
                  "cv"=> 1636661769,
                  "rels"=> [],
                  "links"=> []
                })
              end
            end
          end
        end
      end
    end
  end
end
