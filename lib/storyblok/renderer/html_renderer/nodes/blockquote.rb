module Storyblok::Renderer
  module Nodes
    class Blockquote < Node

      def matching
        @node['type'] === 'blockquote'
      end

      def tag
        'blockquote'
      end
    end
  end
end
