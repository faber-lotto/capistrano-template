module Capistrano
  module Template
    module Helpers
      class PathsLookup < SimpleDelegator
        attr_accessor :paths

        def initialize(paths, context)
          super context
          self.paths = paths
        end

        def template_exists?(filename)
          !template_file(filename).nil?
        end

        def template_file(filename)
          paths_for_file(filename).find { |path| existence_check(path) }
        end

        def existence_check(path)
          File.exist?(path)
        end

        def paths_for_file(filename)
          paths.map do |path|
            path = format(path, host: host)
            ["#{path}/#{filename}.erb", "#{path}/#{filename}"]
          end.flatten
        end
      end
    end
  end
end
