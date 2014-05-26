module Capistrano
  module Template
    module Helpers
      class Renderer < SimpleDelegator
        attr_accessor :from, :reader

        def initialize(from, context, reader: File)
          super context

          self.from = from
          self.reader = reader
        end

        def as_str
          @rendered_template ||= ERB.new(template_content).result(binding)
        end

        def as_io
          StringIO.new(as_str)
        end

        protected

        def template_content
          reader.read(from)
        end
      end
    end
  end
end
