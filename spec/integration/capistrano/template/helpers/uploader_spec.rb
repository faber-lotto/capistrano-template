require 'spec_helper'

module Capistrano
  module Template
    # rubocop: disable Metrics/BlockLength
    module Helpers
      describe Uploader do

        before :each do
          Dir.mkdir(tmp_folder) unless Dir.exist? tmp_folder
        end

        after :each do
          system('rm', '-f', remote_filename) if File.exist? remote_filename
        end

        subject do
          Uploader.new(
              remote_filename,
              context,
              mode: 0640,
              mode_test_cmd: mode_test_cmd,
              digest: digest,
              digest_cmd: digest_cmd,
              io: as_io
          )
        end

        let(:context) do
          Struct.new(:host).new.tap do |cont|
            cont.host = 'localhost'

            allow(cont).to receive(:info)
            allow(cont).to receive(:error)

            def cont.test(*args)
              system(*args)
            end

            def cont.execute(*args)
              system(*args)
            end

            def cont.upload!(io, filename)
              File.write(filename, io.read, mode: 'w')
            end

          end

        end

        let(:tmp_folder) { File.join(__dir__, '..', '..', '..', 'tmp') }

        let(:rendered_template_content) { 'my -- content' }
        let(:as_io) { StringIO.new(rendered_template_content) }

        let(:remote_filename) { File.join(tmp_folder, 'my_template') }

        let(:digest) { Digest::MD5.hexdigest(rendered_template_content) }
        let(:digest_cmd) { %Q{test "Z$(openssl md5 %<path>s| sed "s/^.*= *//")" = "Z%<digest>s" } }

        let(:mode_test_cmd) do
          %Q{ [ "Z$(printf "%%.4o" 0$(stat -c "%%a" %<path>s 2>/dev/null ||  stat -f "%%A" %<path>s))" != "Z%<mode>s" ] }
        end

        describe '#call' do

          it 'uploads a template when content has changed' do
            subject.call
            expect(File.exist?(remote_filename)).to be_truthy
          end

          it 'does not upload a template when content is equal' do
            File.write(remote_filename, rendered_template_content, mode: 'w')

            expect(context).not_to receive(:upload!)
            subject.call
          end

          it 'evals the erb' do
            subject.call
            expect(File.read(remote_filename)).to eq(rendered_template_content)
          end

          it 'sets permissions' do
            File.write(remote_filename, rendered_template_content, mode: 'w')
            File.chmod(0400, remote_filename)

            subject.call

            mode = File.stat(remote_filename).mode & 0xFFF

            expect(mode).to eq(0640)
          end
        end

      end
    end
    # rubocop: enable Metrics/BlockLength
  end
end
