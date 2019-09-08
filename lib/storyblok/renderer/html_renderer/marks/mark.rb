module Storyblok::Renderer
  module Marks
    class Mark
      attr_writer :type

      def type
        @type || 'mark'
      end

      def initialize(data)
        @node = data
      end

      def matching
        false
      end

      def tag
        nil
      end

    end
  end
end
