module Storyblok::Renderer
  module Nodes
    class Blok < Node

      def matching
        @node['type'] === 'blok'
      end

      def html
        body = ''
        @node['attrs']['body'].each do |blok|
          body += component_resolver(blok['component'], blok)
        end
        body
      end

      def component_resolver component, data
        ''
      end
    end
  end
end
