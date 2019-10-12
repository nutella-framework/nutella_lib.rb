require 'spec_helper'
require 'nutella_lib'

describe Nutella do
  describe '#init' do
    before(:each) do
      nutella.init('localhost', 'test_app', 'test_run', 'test_component')
    end
  end
end