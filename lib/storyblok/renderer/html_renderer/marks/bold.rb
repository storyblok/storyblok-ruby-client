module Storyblok::Renderer
  module Marks
    class Bold < Mark

      def matching
        @node['type'] === 'bold'
      end

      def tag
        'b'
      end
    end
  end
end
