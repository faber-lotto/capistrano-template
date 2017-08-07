require 'spec_helper'

module Capistrano
  module Template
    module Helpers
      module Unit # protect from other dummy classes
        module DSLSpec
          class Dummy
            include DSL
            attr_accessor :data, :file_exists

            def initialize
              self.file_exists = true
              self.data = {
                templating_paths: ['/tmp'],
              }
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

            def fetch(*args)
              data.fetch(*args)
            end

            def dry_run?
              true
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
        end

        describe '#template_p' do
          it 'makes underlying call to template' do
            p = {
              :from => 'blah',
              :to   => 'to',
              :mode => '0744',
              :user => 'bob',
              :grp  => 'users',
              :locals => {
                :testkey => 'testval'
              }
            }
            expect(subject).to receive(:template).with(template_name, p[:to], p[:mode], p[:user], p[:group], locals: p[:locals])
            subject.template_p(template_name, p)
          end

          it 'has default values' do
            expect(subject).to receive(:template).with(template_name, nil, Capistrano::Template::Helpers::DSL::MODE_DEFAULT, nil, nil, locals: {})
            subject.template_p(template_name)
          end 
        end
      end

    end
  end
end
