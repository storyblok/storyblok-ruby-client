module Storyblok::Renderer
  module Marks
    class Link < Mark

      def matching
        @node['type'] === 'link'
      end

      def tag
        [{
          tag: "a",
          attrs: @node['attrs'].slice('href', 'target')
        }]
      end
    end
  end
end
