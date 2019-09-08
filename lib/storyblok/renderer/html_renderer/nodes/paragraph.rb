module Storyblok::Renderer
  module Nodes
    class Paragraph < Node

      def matching
        @node['type'] === 'paragraph'
      end

      def tag
        'p'
      end
    end
  end
end
