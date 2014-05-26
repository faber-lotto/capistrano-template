require 'spec_helper'

module Capistrano
  module Template
    module Helpers
      describe Renderer do

        subject do
          Renderer.new(template_name, context, reader: reader)
        end

        let(:context) { OpenStruct.new(var1: 'my', var2: 'content') }
        let(:template_name) { 'my_template' }
        let(:reader) { double(read: template_content) }
        let(:template_content) { '<%=var1%> -- <%=var2%>' }

        describe '#as_str' do

          it 'renders a erb template' do
            expect(subject.as_str).to eq('my -- content')
          end

        end

        describe '#as_io' do
          it 'returns a StringIo' do
            expect(subject.as_io).to be_kind_of StringIO
          end
        end

        describe '.new' do

          it 'is a delegator' do
            expect(context).to receive(:call_it).with(1, 2, 3)
            subject.call_it(1, 2, 3)
          end

        end

      end
    end
  end
end
