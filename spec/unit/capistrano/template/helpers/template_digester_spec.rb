require 'spec_helper'

module Capistrano
  module Template
    module Helpers
      describe TemplateDigester do

        subject do
          TemplateDigester.new(renderer, digest_algo)
        end

        let(:text) { 'my very long text' }
        let(:renderer) { OpenStruct.new(as_str: text) }
        let(:digest_algo) { ->(data) { Digest::MD5.hexdigest(data) } }

        describe '#digest' do

          it 'uses digest_algo to create a digest' do
            expect(subject.digest).to eq(digest_algo.call(text))
          end

        end

        describe '.new' do

          it 'is a delegator' do
            expect(renderer).to receive(:call_it).with(1, 2, 3)
            subject.call_it(1, 2, 3)
          end

        end

      end
    end
  end
end
