require 'spec_helper'

module Capistrano
  module Template
    # rubocop: disable Metrics/ModuleLength, Metrics/BlockLength
    module Helpers
      describe Uploader do

        subject do
          Uploader.new(
              remote_filename_expented,
              upload_handler,
              mode: 0640,
              mode_test_cmd: mode_test_cmd,
              user: 'deploy',
              group: 'www-run',
              user_test_cmd: user_test_cmd,
              digest: digest,
              digest_cmd: digest_cmd,
              io: as_io
          )
        end

        let(:upload_handler) do
          OpenStruct.new(host: 'localhost').tap do |cont|
            allow(cont).to receive(:info)
            allow(cont).to receive(:error)
          end

        end

        let(:rendered_template_content) { 'some text' }
        let(:as_io) { StringIO.new(rendered_template_content) }
        let(:template_name) { 'my_template' }

        let(:remote_filename_expented) { '/var/www/shared/config/database.yml' }

        let(:digest) { Digest::MD5.hexdigest(rendered_template_content) }
        let(:digest_cmd) { %Q(echo "%<digest>s %<path>s" | md5sum -c --status) }
        let(:mode_test_cmd) { %Q{ [ "Z$(printf "%%.4o" 0$(stat -c "%%a" %<path>s 2>/dev/null ||  stat -f "%%A" %<path>s))" != "Z%<mode>s" ] } }
        let(:user_test_cmd) { %Q{ [ "Z$(stat -c "%%U" %<path>s 2>/dev/null)" != "Z%<user>s" ] } }

        describe '#upload_as_file' do

          it 'uploads changed files' do
            allow(subject).to receive(:file_changed?).and_return true
            allow(upload_handler).to receive(:execute).and_return true
            allow(upload_handler).to receive(:upload!).and_return true

            subject.upload_as_file

            expect(upload_handler).to have_received(:upload!).with(as_io, remote_filename_expented)
          end

          it 'deletes a file before upload' do
            allow(subject).to receive(:file_changed?).and_return true
            allow(upload_handler).to receive(:execute).and_return true
            allow(upload_handler).to receive(:upload!).and_return true

            subject.upload_as_file

            expect(upload_handler).to have_received(:execute).with('rm', '-f', remote_filename_expented)
          end

          it 'does not upload unchanged files' do
            allow(subject).to receive(:file_changed?).and_return false

            expect(upload_handler).not_to receive(:upload!)

            subject.upload_as_file
          end

        end

        describe '#set_mode' do
          it 'sets the mode for the remote file' do
            allow(subject).to receive(:permission_changed?).and_return true
            expect(upload_handler).to receive(:execute).with('chmod', '0640', remote_filename_expented)
            subject.set_mode
          end

          it 'sets not the mode for the remote file when nothing changed' do
            allow(subject).to receive(:permission_changed?).and_return false
            expect(upload_handler).not_to receive(:execute)
            subject.set_mode
          end
        end

        describe '#set_user' do
          it 'sets the user for the remote file' do
            allow(subject).to receive(:user_changed?).and_return true

            expect(upload_handler).to receive(:execute).with('sudo', 'chown', 'deploy', remote_filename_expented)

            subject.set_user
          end

          it 'sets not the user for the remote file' do
            allow(subject).to receive(:user_changed?).and_return false
            expect(upload_handler).not_to receive(:execute)
            subject.set_user
          end
        end

        describe '#set_group' do
          it 'sets the group for the remote file' do
            allow(subject).to receive(:group_changed?).and_return true

            expect(upload_handler).to receive(:execute).with('sudo', 'chgrp', 'www-run', remote_filename_expented)

            subject.set_group
          end

          it 'sets not the group for the remote file' do
            allow(subject).to receive(:group_changed?).and_return false
            expect(upload_handler).not_to receive(:execute)
            subject.set_group
          end
        end

        describe '#file_changed?' do
          it 'uses the "digest_cmd" to check file changes' do
            expect(subject).to receive(:__check__).with(%Q(echo "#{digest} /var/www/shared/config/database.yml" | md5sum -c --status))

            subject.file_changed?
          end

          it 'replaces "<digest>"' do
            subject.digest_cmd = '%<digest>s'
            expect(subject).to receive(:__check__).with(digest)

            subject.file_changed?
          end

          it 'replaces "<path>"' do
            allow(subject).to receive(:__check__)
            subject.digest_cmd = '%<path>s'

            subject.file_changed?

            expect(subject).to have_received(:__check__).with(remote_filename_expented)
          end
        end

        describe '#permission_changed?' do
          it 'checks the actual file permissions' do
            allow(subject).to receive(:__check__)
            subject.permission_changed?

            expect(subject).to have_received(:__check__).with(format(mode_test_cmd, mode: '0640', path: remote_filename_expented))
          end
        end

        describe '#user_changed?' do
          it 'returns "false" when no user is given' do
            subject.user = nil
            expect(subject.user_changed?).to be_falsy
          end

          it 'checks the actual user' do
            allow(subject).to receive(:__check__)
            subject.user_changed?
            expect(subject).to have_received(:__check__).with(format(user_test_cmd, user: 'deploy', path: remote_filename_expented))
          end
        end

      end
      # rubocop: enable Metrics/ModuleLength, Metrics/BlockLength
    end
  end
end
