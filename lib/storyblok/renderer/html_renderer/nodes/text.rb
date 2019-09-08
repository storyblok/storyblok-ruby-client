module Storyblok::Renderer
  module Nodes
    class Text < Node

      def matching
        @node['type'] === 'text'
      end

      def text
        @node['text']
      end
    end
  end
end
