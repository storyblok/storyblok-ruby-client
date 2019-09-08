module Storyblok::Renderer
  module Marks
    class Strike < Mark

      def matching
        @node['type'] === 'strike'
      end

      def tag
        'strike'
      end
    end
  end
end
