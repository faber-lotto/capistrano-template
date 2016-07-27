module Capistrano
  module Template
    module Helpers
      module DSL
        def template(from, to = nil, mode = 0640, locals: {})
          fail ::ArgumentError, "template #{from} not found Paths: #{template_paths_lookup.paths_for_file(from).join(':')}" unless template_exists?(from)

          to ||= "#{release_path}/#{File.basename(from, '.erb')}"
          to = remote_path_for(to, true)

          template = _template_factory.call(template_file(from), self, fetch(:templating_digster), locals)

          _uploader_factory.call(to, self,
                                 digest: template.digest,
                                 digest_cmd: fetch(:templating_digest_cmd),
                                 mode_test_cmd: fetch(:templating_mode_test_cmd),
                                 mode: mode,
                                 io: template.as_io
                                ).call
        end

        def template_exists?(template)
          template_paths_lookup.template_exists?(template)
        end

        def template_file(template)
          template_paths_lookup.template_file(template)
        end

        def template_paths_lookup
          _paths_factory.call(fetch(:templating_paths), self)
        end

        def _uploader_factory
          ->(*args) { Uploader.new(*args) }
        end

        def _paths_factory
          ->(*args) { PathsLookup.new(*args) }
        end

        def remote_path_for(path, includes_filename = false)
          filename = nil

          if includes_filename
            filename = File.basename(path)
            path = File.dirname(path)
          end

          remote_path = capture("/bin/bash -c '(cd  #{path} && pwd -P) || readlink -sf #{path}'").chomp

          includes_filename ? File.join(remote_path, filename) : remote_path
        end

        def _template_factory
          ->(from, context, digester, locals) {TemplateDigester.new(Renderer.new(from, context, locals: locals), digester) }
        end

        def method_missing(method_name, *args)
          if self.class.respond_to? method_name
            self.class.send(method_name, *args)
          else
            super
          end
        end
      end
    end
  end
end
