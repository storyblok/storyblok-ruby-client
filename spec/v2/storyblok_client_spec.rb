require_relative '../../lib/storyblok/client'
require_relative '../../lib/storyblok/cache/redis'
require 'redis'
require 'spec_helper'

describe Storyblok::Client do
  subject { described_class.new(token: token, version: version) }
  let(:subject_v1) { described_class.new(api_version: 1, token: token, version: version) }

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
                  "cv"=> 1637246408,
                  "rels"=> [],
                  "links"=> []
                })
              end

              context "using resolve_relations", :vcr do
                it "returns a story with relations resolved", :vcr do
                  expect(subject.story('content-resolve-relations', resolve_relations: 'options-list.options')['data']).to eq(
                    {
                      "story"=>{
                        "name"=>"content resolve relations",
                        "created_at"=>"2021-11-16T19:45:13.233Z",
                        "published_at"=>"2021-11-18T14:40:08.858Z",
                        "id"=>85924760,
                        "uuid"=>"8926c2a6-e0ac-4afd-9132-0f7016699c16",
                        "content"=>{
                          "_uid"=>"7e385817-6fcb-4860-b510-f9b2bc56c7e6",
                          "body"=>[
                            {
                              "_uid"=>"eaf49c11-e254-4609-af43-6840e1d52115",
                              "options"=>[
                                {
                                  "name"=>"simple_content_1",
                                  "created_at"=>"2020-08-20T18:45:52.758Z",
                                  "published_at"=>"2021-11-16T20:46:31.256Z",
                                  "id"=>18409845,
                                  "uuid"=>"542e19cc-ff06-4f19-ae64-a725c89e3406",
                                  "content"=>{
                                    "_uid"=>"e8ac85a4-91eb-42c2-8a18-b6e709b67e9d",
                                    "component"=>"SimpleTextContentType",
                                    "SimpleText"=>"Simple Content Draft"
                                  },
                                  "slug"=>"simple_content_1",
                                  "full_slug"=>"my-folder-slug/simple_content_1",
                                  "sort_by_date"=> nil,
                                  "position"=>0,
                                  "tag_list"=>[],
                                  "is_startpage"=>false,
                                  "parent_id"=>18409844,
                                  "meta_data"=> nil,
                                  "group_id"=>"943ee7f6-b002-44c6-8e26-41b21b6792ea",
                                  "first_published_at"=>"2020-08-20T18:46:39.840Z",
                                  "release_id"=> nil,
                                  "lang"=>"default",
                                  "path"=> nil,
                                  "alternates"=>[],
                                  "default_full_slug"=> nil,
                                  "translated_slugs"=> nil
                                }
                              ],
                              "component"=>"options-list"
                            }
                          ],
                          "component"=>"page"
                        },
                        "slug"=>"content-resolve-relations",
                        "full_slug"=>"content-resolve-relations",
                        "sort_by_date"=> nil,
                        "position"=>-100,
                        "tag_list"=>[],
                        "is_startpage"=>false,
                        "parent_id"=>0,
                        "meta_data"=> nil,
                        "group_id"=>"5f656b63-f64a-4648-aed8-b9ac2ea069e5",
                        "first_published_at"=>"2021-11-16T20:28:35.000Z",
                        "release_id"=> nil,
                        "lang"=>"default",
                        "path"=> nil,
                        "alternates"=>[],
                        "default_full_slug"=> nil,
                        "translated_slugs"=> nil
                      },
                      "cv"=>1637246408,
                      "rels"=>[
                        {
                          "name"=>"simple_content_1",
                          "created_at"=>"2020-08-20T18:45:52.758Z",
                          "published_at"=>"2021-11-16T20:46:31.256Z",
                          "id"=>18409845,
                          "uuid"=>"542e19cc-ff06-4f19-ae64-a725c89e3406",
                          "content"=>{
                            "_uid"=>"e8ac85a4-91eb-42c2-8a18-b6e709b67e9d",
                            "component"=>"SimpleTextContentType",
                            "SimpleText"=>"Simple Content Draft"
                          },
                          "slug"=>"simple_content_1",
                          "full_slug"=>"my-folder-slug/simple_content_1",
                          "sort_by_date"=> nil,
                          "position"=>0,
                          "tag_list"=>[],
                          "is_startpage"=>false,
                          "parent_id"=>18409844,
                          "meta_data"=> nil,
                          "group_id"=>"943ee7f6-b002-44c6-8e26-41b21b6792ea",
                          "first_published_at"=>"2020-08-20T18:46:39.840Z",
                          "release_id"=> nil,
                          "lang"=>"default",
                          "path"=> nil,
                          "alternates"=>[],
                          "default_full_slug"=> nil,
                          "translated_slugs"=> nil
                        }
                      ],
                      "links"=>[]
                    }
                  )
                end
              end

              context "using resolve_relations string key", :vcr do
                it "returns a story with relations resolved", :vcr do
                  expect(subject.story('content-resolve-relations', "resolve_relations" => 'options-list.options')['data']).to eq(
                    {
                      "story"=>{
                        "name"=>"content resolve relations",
                        "created_at"=>"2021-11-16T19:45:13.233Z",
                        "published_at"=>"2021-11-18T14:40:08.858Z",
                        "id"=>85924760,
                        "uuid"=>"8926c2a6-e0ac-4afd-9132-0f7016699c16",
                        "content"=>{
                          "_uid"=>"7e385817-6fcb-4860-b510-f9b2bc56c7e6",
                          "body"=>[
                            {
                              "_uid"=>"eaf49c11-e254-4609-af43-6840e1d52115",
                              "options"=>[
                                {
                                  "name"=>"simple_content_1",
                                  "created_at"=>"2020-08-20T18:45:52.758Z",
                                  "published_at"=>"2021-11-16T20:46:31.256Z",
                                  "id"=>18409845,
                                  "uuid"=>"542e19cc-ff06-4f19-ae64-a725c89e3406",
                                  "content"=>{
                                    "_uid"=>"e8ac85a4-91eb-42c2-8a18-b6e709b67e9d",
                                    "component"=>"SimpleTextContentType",
                                    "SimpleText"=>"Simple Content Draft"
                                  },
                                  "slug"=>"simple_content_1",
                                  "full_slug"=>"my-folder-slug/simple_content_1",
                                  "sort_by_date"=> nil,
                                  "position"=>0,
                                  "tag_list"=>[],
                                  "is_startpage"=>false,
                                  "parent_id"=>18409844,
                                  "meta_data"=> nil,
                                  "group_id"=>"943ee7f6-b002-44c6-8e26-41b21b6792ea",
                                  "first_published_at"=>"2020-08-20T18:46:39.840Z",
                                  "release_id"=> nil,
                                  "lang"=>"default",
                                  "path"=> nil,
                                  "alternates"=>[],
                                  "default_full_slug"=> nil,
                                  "translated_slugs"=> nil
                                }
                              ],
                              "component"=>"options-list"
                            }
                          ],
                          "component"=>"page"
                        },
                        "slug"=>"content-resolve-relations",
                        "full_slug"=>"content-resolve-relations",
                        "sort_by_date"=> nil,
                        "position"=>-100,
                        "tag_list"=>[],
                        "is_startpage"=>false,
                        "parent_id"=>0,
                        "meta_data"=> nil,
                        "group_id"=>"5f656b63-f64a-4648-aed8-b9ac2ea069e5",
                        "first_published_at"=>"2021-11-16T20:28:35.000Z",
                        "release_id"=> nil,
                        "lang"=>"default",
                        "path"=> nil,
                        "alternates"=>[],
                        "default_full_slug"=> nil,
                        "translated_slugs"=> nil
                      },
                      "cv"=>1637263402,
                      "rels"=>[
                        {
                          "name"=>"simple_content_1",
                          "created_at"=>"2020-08-20T18:45:52.758Z",
                          "published_at"=>"2021-11-16T20:46:31.256Z",
                          "id"=>18409845,
                          "uuid"=>"542e19cc-ff06-4f19-ae64-a725c89e3406",
                          "content"=>{
                            "_uid"=>"e8ac85a4-91eb-42c2-8a18-b6e709b67e9d",
                            "component"=>"SimpleTextContentType",
                            "SimpleText"=>"Simple Content Draft"
                          },
                          "slug"=>"simple_content_1",
                          "full_slug"=>"my-folder-slug/simple_content_1",
                          "sort_by_date"=> nil,
                          "position"=>0,
                          "tag_list"=>[],
                          "is_startpage"=>false,
                          "parent_id"=>18409844,
                          "meta_data"=> nil,
                          "group_id"=>"943ee7f6-b002-44c6-8e26-41b21b6792ea",
                          "first_published_at"=>"2020-08-20T18:46:39.840Z",
                          "release_id"=> nil,
                          "lang"=>"default",
                          "path"=> nil,
                          "alternates"=>[],
                          "default_full_slug"=> nil,
                          "translated_slugs"=> nil
                        }
                      ],
                      "links"=>[]
                    }
                  )
                end
              end

              context "using resolve_links", :vcr do
                it "returns a story with links resolved" do
                  expect(subject.story('content-resolve-links', resolve_links: 1)['data']).to eq({
                    "story"=> {
                      "name"=> "content resolve links",
                      "created_at"=> "2021-11-18T17:43:08.695Z",
                      "published_at"=> "2021-11-18T19:23:22.657Z",
                      "id"=> 86436757,
                      "uuid"=> "e93f2707-775c-41d4-8ad5-413975318d93",
                      "content"=> {
                        "_uid"=> "d8e13705-ddf8-4f4f-8432-d3baece5ec23",
                        "body"=> [],
                        "component"=> "page",
                        "link_to_story"=> {
                          "id"=> "fe520269-b092-482c-94c4-8028eb81af41",
                          "url"=> "",
                          "anchor"=> "",
                          "linktype"=> "story",
                          "fieldtype"=> "multilink",
                          "cached_url"=> "simple_content",
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
                          }
                        },
                        "link_to_story_2"=> {
                          "id"=> "",
                          "url"=> "",
                          "linktype"=> "url",
                          "fieldtype"=> "multilink",
                          "cached_url"=> ""
                        }
                      },
                      "slug"=> "content-resolve-links",
                      "full_slug"=> "content-resolve-links",
                      "sort_by_date"=> nil,
                      "position"=> -110,
                      "tag_list"=> [],
                      "is_startpage"=> false,
                      "parent_id"=> 0,
                      "meta_data"=> nil,
                      "group_id"=> "7f03b8db-6237-48b4-abd7-6bc8a0f459c8",
                      "first_published_at"=> "2021-11-18T17:51:19.000Z",
                      "release_id"=> nil,
                      "lang"=> "default",
                      "path"=> nil,
                      "alternates"=> [],
                      "default_full_slug"=> nil,
                      "translated_slugs"=> nil
                    },
                    "cv"=> 1637263402,
                    "rels"=> [],
                    "links"=> [
                      {
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
                      }
                    ]
                  })
                end
              end

              context "comparing v2 and v1 to assure backward compatibility", :vcr do
                it "returns difference in translated_slug default value" do
                  v2_content = subject.story("content-resolve-relations", resolve_relations: "options-list.options", cv: 1)["data"]["story"]
                  v1_content = subject_v1.story("content-resolve-relations", resolve_relations: "options-list.options", cv: 1)["data"]["story"]

                  expect(Hashdiff.diff(v2_content, v1_content)).to eq [["~", "content.body[0].options[0].translated_slugs", nil, []], ["~", "translated_slugs", nil, []]]
                end
              end
            end
          end
        end
      end
    end
  end
end
