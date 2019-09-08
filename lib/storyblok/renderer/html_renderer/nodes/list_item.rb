module Storyblok::Renderer
  module Nodes
    class ListItem < Node
      def matching
        @node['type'] === 'list_item'
      end

      def tag
        'li'
      end
    end
  end
end
