require 'spec_helper'

describe Capistrano::Template do
  it 'should have a version number' do
    Capistrano::Template::VERSION.should_not be_nil
  end
end
