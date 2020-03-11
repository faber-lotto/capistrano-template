module Capistrano
  module Template
    module Helpers
      module DSL
        # rubocop: disable Metrics/AbcSize
        def template(from, to = nil, mode = 0640, user = nil, group = nil, locals: {})
          fail ::ArgumentError, "template #{from} not found Paths: #{template_paths_lookup.paths_for_file(from).join(':')}" unless template_exists?(from)

          return if dry_run?

          template = _template_factory.call(template_file(from), self, fetch(:templating_digster), locals)

          _uploader_factory.call(get_to(to, from), self,
                                 digest: template.digest,
                                 digest_cmd: fetch(:templating_digest_cmd),
                                 mode_test_cmd: fetch(:templating_mode_test_cmd),
                                 user_test_cmd: fetch(:templating_user_test_cmd),
                                 group_test_cmd: fetch(:templating_group_test_cmd),
                                 mode: mode,
                                 user: user,
                                 group: group,
                                 io: template.as_io
                                ).call
        end
        # rubocop: enable Metrics/AbcSize

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
          ->(*args, **options) { Uploader.new(*args, **options) }
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

          cd_cmd = "cd #{path}"
          cd_cmd = "cd #{pwd_path}; #{cd_cmd}" if pwd_path

          remote_path = capture("/bin/bash -c '(#{cd_cmd} && pwd -P) || readlink -sf #{path}'").chomp

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

        def dry_run?
          if ::Capistrano::Configuration.respond_to?(:dry_run?)
            ::Capistrano::Configuration.dry_run?
          else
            ::Capistrano::Configuration.env.send(:config)[:sshkit_backend] == SSHKit::Backend::Printer
          end
        end

        def get_to(to, from)
          to ||= "#{release_path}/#{File.basename(from, '.erb')}"
          remote_path_for(to, true)
        end
      end
    end
  end
end
