module Storyblok::Renderer
  module Nodes
    class HorizontalRule < Node

      def matching
        @node['type'] === 'horizontal_rule'
      end

      def single_tag
        'hr'
      end
    end
  end
end
