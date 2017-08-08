require 'spec_helper'

module Capistrano
  module Template
    module Helpers
      module Unit # protect from other dummy classes
        module DSLSpec
          class Dummy
            include DSL
            attr_accessor :data, :file_exists, :dry_run, :uploader, :local_mode

            def initialize
              self.file_exists = true
              self.data = {
                templating_digster: ->(data) { Digest::MD5.hexdigest(data) },
                templating_digest_cmd: '',
                templating_mode_test_cmd: '',
                templating_user_test_cmd: '',
                templating_group_test_cmd: '',
                templating_paths: ['/tmp'],
              }
              self.dry_run = true
              self.local_mode = 33_188
              @fake_digest = OpenStruct.new
              @fake_digest.digest = '_digest_'
              self.uploader = nil
            end

            def host
              'localhost'
            end

            def release_path
              '/var/www/app/releases/20140510'
            end

            def pwd_path
              nil
            end

            def dry_run?
              dry_run
            end

            def test(*)
              true
            end

            def info(*) end

            def execute(*) end

            def capture(*)
              '_capture_'
            end

            def fetch(*args)
              data.fetch(*args)
            end

            def _template_factory
              ->(_from, _context, _digester, _locals) { @fake_digest }
            end

            def _uploader_factory
              ->(*args) { self.uploader = Uploader.new(*args) }
            end

            def get_local_mode(*)
              local_mode
            end

            def _paths_factory
              lambda do |*args|
                PathsLookup.new(*args).tap do |pl|
                  def pl.existence_check(*)
                    file_exists
                  end
                end
              end
            end
          end
        end
      end

      # rubocop: disable Metrics/BlockLength
      describe DSL do
        subject do
          Unit::DSLSpec::Dummy.new
        end

        let(:template_name) { 'my_template.erb' }

        describe '#template' do
          it 'raises an exception when template does not exists' do
            subject.file_exists = false
            expect { subject.template(template_name) }.to raise_error(ArgumentError, /template #{template_name} not found Paths/)
          end

          it 'has a default mode' do
            subject.dry_run = false
            subject.template(template_name)
            expect(subject.uploader.mode).to equal(Capistrano::Template::Helpers::DSL::MODE_DEFAULT)
          end

          it 'handles nil mode' do
            subject.dry_run = false
            subject.template(template_name, nil, nil)
            expect(subject.uploader.mode).to equal(Capistrano::Template::Helpers::DSL::MODE_DEFAULT)
          end

          it 'can match the mode of the local file' do
            subject.dry_run = false
            subject.template(template_name, nil, nil, nil, nil, true)
            expect(subject.uploader.mode).to equal(subject.local_mode & Capistrano::Template::Helpers::DSL::MODE_MASK)
          end
        end

        describe '#template_p' do
          it 'makes underlying call to template' do
            p = {
              from:   'blah',
              to:     'to',
              mode:   '0744',
              user:   'bob',
              group:  'users',
              match_local_mode: true,
              locals: {
                testkey: 'testval'
              }
            }
            expect(subject).to receive(:template).with(template_name, p[:to], p[:mode], p[:user], p[:group], p[:match_local_mode], locals: p[:locals])
            subject.template_p(template_name, p)
          end

          it 'has default values' do
            expect(subject).to receive(:template).with(template_name, nil, Capistrano::Template::Helpers::DSL::MODE_DEFAULT, nil, nil, false, locals: {})
            subject.template_p(template_name)
          end

          it 'can match the mode of the local file' do
            subject.dry_run = false
            subject.template_p(template_name, match_local_mode: true)
            expect(subject.uploader.mode).to equal(subject.local_mode & Capistrano::Template::Helpers::DSL::MODE_MASK)
          end
        end
      end
      # rubocop: enable Metrics/BlockLength
    end
  end
end
