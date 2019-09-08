module Storyblok::Renderer
  module Marks
    class Code < Mark

      def matching
        @node['type'] === 'code'
      end

      def tag
        'code'
      end
    end
  end
end
