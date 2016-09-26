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
      end
    end
  end
end
