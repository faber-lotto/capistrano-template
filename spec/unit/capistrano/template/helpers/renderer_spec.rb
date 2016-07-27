require 'spec_helper'

module Capistrano
  module Template
    module Helpers
      describe Renderer do

        subject do
          Renderer.new(template_name, context, reader: reader, locals: locals)
        end

        let(:context) { OpenStruct.new(var1: 'my', var2: 'content') }
        let(:locals) { { 'my_local' => 'local content' } }
        let(:template_name) { 'my_template' }
        let(:reader) { double(read: template_content) }
        let(:template_content) { '<%=var1%> -- <%=var2%> -- <%= my_local %>' }

        describe '#as_str' do

          it 'renders a erb template' do
            expect(subject.as_str).to eq('my -- content -- local content')
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

        describe '.respond_to?' do
          it 'returns "true" when method name is a key inside the locals hash' do
            expect(subject.respond_to?(:my_local)).to be_truthy
          end

          it 'returns "false" when method name is not a key inside the locals hash and context does not respond to this method' do
            expect(subject.respond_to?(:foo)).to be_falsy
          end
        end

      end
    end
  end
end
