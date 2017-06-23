require 'spec_helper'

module Capistrano
  module Template
    module Helpers
      # rubocop: disable Metrics/BlockLength
      describe PathsLookup do
        subject do
          PathsLookup.new(lookup_paths, context)
        end

        let(:tmp_folder) { File.join(__dir__, '..', '..', '..', 'tmp') }

        let(:lookup_paths) { ["#{tmp_folder}/%<host>s", "#{tmp_folder}"] }
        let(:context) { OpenStruct.new(host: 'localhost') }

        let(:template_content) { '<%=var1%> -- <%=var2%>' }
        let(:template_name) { 'my_template.erb' }
        let(:template_fullname) { File.join(tmp_folder, template_name) }

        before :each do
          Dir.mkdir(tmp_folder) unless Dir.exist? tmp_folder
          File.write(template_fullname, template_content, mode: 'w')
        end

        after :each do
          if File.exist? template_fullname
            system('rm', '-f', File.join(tmp_folder, template_fullname))
          end
        end

        describe '#template_exists?' do

          it 'returns true when a template file exists' do
            expect(subject.template_exists?(template_name)).to be_truthy
          end

          it 'returns false when a template does not file exists' do
            expect(subject.template_exists?("#{template_name}.not_exists")).to be_falsy
          end

        end

      end
      # rubocop: enable Metrics/BlockLength
    end
  end
end
