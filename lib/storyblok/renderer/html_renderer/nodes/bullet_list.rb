module Storyblok::Renderer
  module Nodes
    class BulletList < Node

      def matching
        @node['type'] === 'bullet_list'
      end

      def tag
        'ul'
      end
    end
  end
end
