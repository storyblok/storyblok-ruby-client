require "cgi"

module Storyblok
  module Renderer
    require_relative "html_renderer/marks/mark"
    require_relative "html_renderer/marks/strike"
    require_relative "html_renderer/marks/underline"
    require_relative "html_renderer/marks/bold"
    require_relative "html_renderer/marks/strong"
    require_relative "html_renderer/marks/code"
    require_relative "html_renderer/marks/italic"
    require_relative "html_renderer/marks/link"
    require_relative "html_renderer/nodes/node"
    require_relative "html_renderer/nodes/bullet_list"
    require_relative "html_renderer/nodes/code_block"
    require_relative "html_renderer/nodes/hard_break"
    require_relative "html_renderer/nodes/heading"
    require_relative "html_renderer/nodes/image"
    require_relative "html_renderer/nodes/list_item"
    require_relative "html_renderer/nodes/ordered_list"
    require_relative "html_renderer/nodes/paragraph"
    require_relative "html_renderer/nodes/text"
    require_relative "html_renderer/nodes/blockquote"
    require_relative "html_renderer/nodes/horizontal_rule"
    require_relative "html_renderer/nodes/text"
    require_relative "html_renderer/nodes/blok"

    class HtmlRenderer
      def initialize
        @marks = [
          Storyblok::Renderer::Marks::Bold,
          Storyblok::Renderer::Marks::Strike,
          Storyblok::Renderer::Marks::Underline,
          Storyblok::Renderer::Marks::Strong,
          Storyblok::Renderer::Marks::Code,
          Storyblok::Renderer::Marks::Italic,
          Storyblok::Renderer::Marks::Link
        ]
        @nodes = [
          Storyblok::Renderer::Nodes::HorizontalRule,
          Storyblok::Renderer::Nodes::Blockquote,
          Storyblok::Renderer::Nodes::BulletList,
          Storyblok::Renderer::Nodes::CodeBlock,
          Storyblok::Renderer::Nodes::HardBreak,
          Storyblok::Renderer::Nodes::Heading,
          Storyblok::Renderer::Nodes::Image,
          Storyblok::Renderer::Nodes::ListItem,
          Storyblok::Renderer::Nodes::OrderedList,
          Storyblok::Renderer::Nodes::Paragraph,
          Storyblok::Renderer::Nodes::Text,
          Storyblok::Renderer::Nodes::Blok
        ]
      end

      def set_component_resolver(component_resolver)
        Storyblok::Renderer::Nodes::Blok.define_method :component_resolver, component_resolver
      end

      def add_node(node)
        @nodes.push(node)
      end

      def add_mark(mark)
        @marks.push(mark)
      end

      def render(data)
        html = ""
        data['content'].each do |node|
          html += render_node(node)
        end

        html
      end

      private

      def render_node(item)
        html = []
        if item['marks']
          item['marks'].each do |m|
            mark = get_matching_mark(m)
            html.push(render_opening_tag(mark.tag)) if mark
          end
        end

        node = get_matching_node(item)
        html.push(render_opening_tag(node.tag)) if node and node.tag

        if item['content']
          item['content'].each do |content|
            html.push(render_node(content))
          end
        elsif node and node.text
          html.push(CGI.escapeHTML(node.text))
        elsif node and node.single_tag
          html.push(render_tag(node.single_tag))
        elsif node and node.html
          html.push(node.html)
        end

        html.push(render_closing_tag(node.tag)) if node and node.tag
        if item['marks']
          item['marks'].reverse.each do |m|
            mark = get_matching_mark(m)
            html.push(render_closing_tag(mark.tag)) if mark
          end
        end
        return html.join("")
      end

      def render_tag(tags, ending = ' /')
        return "<#{tags}#{ending}>" if tags.is_a? String
        all = tags.map do |tag|
          if tag.is_a? String
            "<#{tag}#{ending}>"
          else
            h = "<#{tag[:tag]}"
            tag[:attrs].to_h.each_pair { |key, value| h += " #{key}=\"#{CGI.escapeHTML(value)}\"" if !value.nil? } if tag[:attrs]
            "#{h}#{ending}>"
          end
        end
        return all.join('')
      end

      def render_opening_tag(tags)
        render_tag(tags, '')
      end

      def render_closing_tag(tags)
        return "</#{tags}>" if tags.is_a? String

        all = tags.reverse.map do |tag|
          if tag.is_a? String
            "</#{tag}>"
          else
            "</#{tag[:tag]}>"
          end
        end
        return all.join('')
      end

      def get_matching_node(item)
        return get_matching_class(item, @nodes)
      end

      def get_matching_mark(item)
        return get_matching_class(item, @marks)
      end

      def get_matching_class(node, classes)
        found = classes.select do |clazz|
          instance = clazz.new(node)
          if (instance.matching())
            return instance
          end
        end
        found.first
      end
    end
  end
end
