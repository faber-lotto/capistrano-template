require 'spec_helper'

module Capistrano
  module Template
    module Helpers
      module Unit # protect from other dummy classes
        module DSLSpec
          class DummyDryRun
            include DSL
            def template_exists?
              true
            end

            def dry_run?
              true
            end
          end
        end
      end

      describe DSL do
        subject do
          Unit::DSLSpec::DummyDryRun.new
        end

        describe '#template dry run' do
          it 'do nothing' do
            expect(subject).not_to receive(:_template_factory)
          end
        end
      end
    end
  end
end
