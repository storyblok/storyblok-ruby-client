module Storyblok::Renderer
  module Nodes
    class Heading < Node

      def matching
        @node['type'] === 'heading'
      end

      def tag
        "h#{@node['attrs']['level']}"
      end
    end
  end
end
