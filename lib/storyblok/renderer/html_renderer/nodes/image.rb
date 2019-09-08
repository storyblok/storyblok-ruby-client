module Storyblok::Renderer
  module Nodes
    class Image < Node

      def matching
        @node['type'] === 'image'
      end

      def single_tag
        [{
          tag: "img",
          attrs: @node['attrs'].slice('src', 'alt', 'title')
        }]
      end
    end
  end
end
