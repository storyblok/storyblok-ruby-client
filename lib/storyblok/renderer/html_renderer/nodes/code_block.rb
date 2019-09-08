module Storyblok::Renderer
  module Nodes
    class CodeBlock < Node

      def matching
        @node['type'] === 'code_block'
      end

      def tag
        [
          'pre',
          {
            tag: 'code',
            attrs: @node['attrs'].slice('class')
          }
        ]
      end
    end
  end
end
