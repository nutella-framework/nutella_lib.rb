require 'spec_helper'
require 'stubs/fake_mqtt_client'
require 'nutella_lib'


describe Nutella do
  
  describe '#init' do
    let(:mqtt_client){ MQTT::FakeMQTTClient.new }
    before { allow(MQTT::Client).to receive(:connect).and_return(mqtt_client) }
    it 'initializes correctly' do
      nutella.f.init('localhost', 'test_component')
    end
  end

  describe 'basic methods' do
    # before(:each) do
    #   nutella.f.init('localhost', 'test_app', 'test_run', 'test_component')
    # end
  end

end