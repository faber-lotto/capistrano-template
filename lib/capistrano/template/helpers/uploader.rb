module Capistrano
  module Template
    module Helpers
      require 'capistrano/template/helpers/renderer'
      require 'capistrano/template/helpers/template_digester'

      class Uploader
        attr_accessor :io,
                      :digest,
                      :full_to_path,
                      :digest_cmd,
                      :mode,
                      :remote_handler,
                      :mode_test_cmd

        def initialize(full_to_path, remote_handler,
            mode: 0640,
            mode_test_cmd: nil,
            digest: nil,
            digest_cmd: nil,
            io: nil
        )
          self.remote_handler = remote_handler

          self.full_to_path = full_to_path

          self.digest_cmd = digest_cmd
          self.mode = mode
          self.mode_test_cmd = mode_test_cmd

          self.io = io
          self.digest = digest
        end

        def call
          upload_as_file
          set_mode
        end

        def upload_as_file
          if file_changed?
            remote_handler.info "copying to: #{full_to_path}"
            remote_handler.upload! io, full_to_path
          else
            remote_handler.info "File #{full_to_path} on host #{host} not changed"
          end
        end

        def host
          remote_handler.host
        end

        def set_mode
          if permission_changed?
            remote_handler.info "permission changed for file #{full_to_path} on #{host} set new permissions"
            remote_handler.execute 'chmod', octal_mode_str, full_to_path
          else
            remote_handler.info "permission not changed for file #{full_to_path} on #{host}"
          end
        end

        def file_changed?
          !__check__(digest_cmd)
        end

        def permission_changed?
          __check__(mode_test_cmd)
        end

        protected

        def __check__(*args)
          remote_handler.test(*args)
        end

        def octal_mode_str
          format '%.4o' , mode
        end

        def digest_cmd
          @digest_cmd % { digest: digest,
                          path: full_to_path }
        end

        def mode_test_cmd
          @mode_test_cmd % {
            path: full_to_path,
            mode: octal_mode_str
          }
        end
      end
    end
  end
end
