module Storyblok::Renderer
  module Marks
    class Italic < Mark

      def matching
        @node['type'] === 'italic'
      end

      def tag
        'i'
      end
    end
  end
end
