require 'spec_helper'

module Capistrano
  module Template
    # rubocop: disable Metrics/BlockLength
    module Helpers
      describe PathsLookup do
        subject do
          PathsLookup.new(lookup_paths, context)
        end

        let(:lookup_paths) { ['path1/%<host>s', 'path2'] }
        let(:context) { OpenStruct.new(host: 'localhost') }
        let(:template_name) { 'my_template' }

        describe '#template_exists?' do

          it 'returns true when a template file exists' do
            allow(subject).to receive(:existence_check).and_return(true)
            expect(subject.template_exists?(template_name)).to be_truthy
          end

          it 'returns false when a template does not file exists' do
            allow(subject).to receive(:existence_check).and_return(false)
            expect(subject.template_exists?(template_name)).to be_falsy
          end

          it 'checks for every possible path existence' do
            expect(subject).to receive(:existence_check).exactly(lookup_paths.count * 2).times
            subject.template_exists?(template_name)
          end

          it 'stops search for first hit' do
            expect(subject).to receive(:existence_check).exactly(2).times.and_return(false, true)
            subject.template_exists?(template_name)
          end

        end

        describe '#template_file' do
          it 'returns the first found filename' do
            allow(subject).to receive(:existence_check).and_return(false, false, true)
            expect(subject.template_file(template_name)).to eq('path2/my_template.erb')
          end

          it 'expends the host' do
            allow(subject).to receive(:existence_check).and_return(true)
            expect(subject.template_file(template_name)).to eq('path1/localhost/my_template.erb')
          end
        end

      end
    end
    # rubocop: enable Metrics/BlockLength
  end
end
