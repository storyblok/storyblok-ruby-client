module Storyblok::Renderer
  module Nodes

    class Node
      attr_writer :wrapper
      attr_writer :type

      def type
        @type || 'node'
      end

      def initialize(data)
        @node = data
      end

      def matching
        false
      end

      def single_tag
        nil
      end

      def tag
        nil
      end

      def text
        nil
      end

      def html
        nil
      end
    end
  end
end
