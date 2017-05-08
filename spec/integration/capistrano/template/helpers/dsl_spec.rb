require 'spec_helper'

module Capistrano
  module Template
    module Helpers
      module Integration # prodect from other dummy classes
        module DSLSpec
          class Dummy
            include DSL
            attr_accessor :data, :release_path

            def initialize
              self.data = {
                templating_digster: ->(data) { Digest::MD5.hexdigest(data) },
                templating_digest_cmd: %Q(echo "%<digest>s %<path>s" | md5sum -c --status ),
                templating_mode_test_cmd: %Q{ [ "Z$(printf "%%.4o" 0$(stat -c "%%a" %<path>s 2>/dev/null ||  stat -f "%%A" %<path>s))" != "Z%<mode>s" ] },
                templating_user_test_cmd: %Q{ [ "Z$(stat -c "%%U" %<path>s 2>/dev/null)" != "Z%<user>s" ] },
                templating_group_test_cmd: %Q{ [ "Z$(stat -c "%%G" %<path>s 2>/dev/null)" != "Z%<group>s" ] }
              }
            end

            # custom methods
            def var1
              'my'
            end

            def var2
              'content'
            end

            # capistrano method
            def fetch(*args)
              data.fetch(*args)
            end

            # sshkit methods

            def host
              'localhost'
            end

            def test(*args)
              execute(*args)
            end

            def execute(*args)
              system(*args)
            end

            def upload!(io, filename)
              File.write(filename, io.read, mode: 'w')
            end

            def capture(cmd)
              `#{cmd}`
            end

            def info(*); end

            def error(*); end

            def pwd_path; end

            def dry_run?
              false
            end
          end
        end
      end

      # rubocop:disable Metrics/BlockLength
      describe DSL do
        subject do
          Integration::DSLSpec::Dummy.new.tap do |d|
            d.data[:templating_paths] = [tmp_folder]
            d.release_path = tmp_folder
          end
        end

        let(:template_name) { 'my_template.erb' }

        let(:tmp_folder) { File.join(__dir__, '..', '..', '..', 'tmp') }

        let(:template_content) { '<%=var1%> -- <%=var2%> -- <%= my_local %>' }
        let(:expected_content) { 'my -- content -- local content' }
        let(:locals) { { 'my_local' => 'local content' } }

        let(:template_name) { 'my_template.erb' }
        let(:template_fullname) { File.join(tmp_folder, template_name) }
        let(:remote_filename) { File.join(tmp_folder, 'my_template') }

        let(:digest_algo) { ->(data) { Digest::MD5.hexdigest(data) } }
        let(:digest_cmd) { %Q{test "Z$(openssl md5 %<path>s| sed "s/^.*= *//")" = "Z%<digest>s" } }

        let(:mode_test_cmd) do
          %Q{ [ "Z$(printf "%%.4o" 0$(stat -c "%%a" %<path>s 2>/dev/null ||  stat -f "%%A" %<path>s))" != "Z%<mode>s" ] }
        end

        before :each do
          Dir.mkdir(tmp_folder) unless Dir.exist? tmp_folder
          File.write(template_fullname, template_content, mode: 'w')
        end

        after :each do
          [
            template_fullname,
            remote_filename
          ].each do |f|
            system('rm', '-f', f) if File.exist? f
          end
        end

        describe '#template' do

          it 'create the result file' do
            subject.template(template_name, locals: locals)

            expect(File.read(remote_filename)).to eq(expected_content)
          end

        end
      end
      # rubocop:enable Metrics/BlockLength
    end
  end
end
