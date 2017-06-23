module Capistrano
  module Template
    module Helpers
      class Renderer < SimpleDelegator
        attr_accessor :from, :reader, :locals

        def initialize(from, context, reader: File, locals: {})
          super context

          self.from = from
          self.reader = reader
          self.locals = locals
        end

        def locals=(new_locals)
          new_locals ||= {}
          new_locals = new_locals.each_with_object({}) { |(key, value), result| result[key.to_sym] = value }
          @locals = new_locals
        end

        def as_str
          @rendered_template ||= ERB.new(template_content, nil, '-').result(binding)
        end

        def as_io
          StringIO.new(as_str)
        end

        def method_missing(m, *args, &block)
          if locals.key?(m)
            locals[m]
          else
            super
          end
        end

        def render(from, indent: 0, locals: {})
          template = template_file(from)
          content  = Renderer.new(template, self, reader: reader, locals: self.locals.merge(locals)).as_str

          indented_content(content, indent)
        end

        def indented_content(content, indent)
          content.split("\n").map { |line| "#{' ' * indent}#{line}" }.join("\n")
        end

        def respond_to_missing?(m, include_private)
          if locals.key?(m)
            true
          else
            super
          end
        end

        protected

        def template_content
          reader.read(from)
        end
      end
    end
  end
end
