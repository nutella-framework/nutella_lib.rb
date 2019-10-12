require 'spec_helper'
require 'simple_mqtt_client/simple_mqtt_client'

describe SimpleMQTTClient do
    
    describe '#initialize' do
        context 'with a non existing broker' do
            it 'raises and error' do
                expect { SimpleMQTTClient.new('localhost') }.to raise_error(Errno::ECONNREFUSED)
            end
        end
    end

    describe '#subscribe' do
        before(:each) do
            mqtt_client = instance_double('MQTT::Client')
            MQTT::Client.stub(:connect).and_return(mqtt_client)
        end

        context 'to params are passed correctly' do
            let(:client) { SimpleMQTTClient.new('localhost') }
        end
    end

    describe '#unsubscribe' do
    end

    describe '#publish' do
    end

    describe '#subscriptions' do
    end
end

# server = double('server').as_null_object
# TCPSocket.stub(:new).and_return(server)


# @obj = MyClass.new
# result = @obj.send(:my_private_method, arguments)
# expect(....)

  # def test_connect_and_send_receive_messages_correctly
  #   cb_executed = false
  #   sc1 = SimpleMQTTClient.new 'ltg.evl.uic.edu'
  #   cb1 = lambda do |message|
  #     cb_executed = true
  #     assert_equal 'test-message-1', message
  #     sc1.unsubscribe 'demo1', cb1
  #   end
  #   sc1.subscribe('demo1', cb1)
  
  #   sc2 = SimpleMQTTClient.new 'ltg.evl.uic.edu'
  #   sc2.publish('demo1', 'test-message-1')
  #   # Make sure we wait for the message to be delivered
  #   sleep(1)
  #   assert cb_executed
  # end
  
  
  # def test_list_current_subscriptions_correctly
  #   sc3 = SimpleMQTTClient.new 'ltg.evl.uic.edu'
  #   cb2 = lambda {|message| puts message}
  #   cb3 = lambda {|message| puts message}
  #   sc3.subscribe( 'channel_1', cb2 )
  #   sc3.subscribe( 'channel_2', cb2 )
  #   sc3.subscribe( 'channel_3', cb2 )
  #   sc3.subscribe( 'channel_3', cb3 )
  #   assert_equal sc3.get_subscribed_channels['channel_3'].length, 2
  #   sc3.unsubscribe( 'channel_3', cb2 )
  #   assert_equal sc3.get_subscribed_channels['channel_3'].length, 1
  # end
  #
  #
  # def test_recognize_wildcard_patters_correctly
  #   sc4 = SimpleMQTTClient.new 'ltg.evl.uic.edu'
  #   sc4.subscribe('run_id/#', lambda {|m| puts m})
  #   refute_nil sc4.send(:get_callbacks, 'run_id/one')
  #   refute_nil sc4.send(:get_callbacks, 'run_id/one/two')
  # end


  # def test_multiple_simple_subscriptions
  #   sc5 = SimpleMQTTClient.new 'ltg.evl.uic.edu'
  #   total = 0
  #   cb1 = lambda { |message| total += 3; puts "CB1: #{message}"}
  #   cb2 = lambda { |message| total += 1; puts "CB2: #{message}"}
  #   sc5.subscribe('demo2', cb1)
  #   sc5.subscribe('demo2', cb2)
  #   sc6 = SimpleMQTTClient.new 'ltg.evl.uic.edu'
  #   sc6.publish('demo2', 'test-message-2')
  #   # Make sure we wait for the message to be delivered
  #   sleep(1)
  #   assert_equal total, 4
  # end


  # def test_multiple_mixed_subscriptions
  #   sc6 = SimpleMQTTClient.new 'ltg.evl.uic.edu'
  #   total = 0
  #   cba = lambda { |message| total += 1; puts "CBA: #{message}"}
  #   cbb = lambda { |message| total += 2; puts "CBB: #{message}"}
  #   cbc = lambda { |message| total += 3; puts "CBC: #{message}"}
  #   sc6.subscribe('demo4/demo5/demo6', cba)
  #   sc6.subscribe('demo4/demo5/#', cbb)
  #   sc6.subscribe('demo4/+/demo6', cbc)
  #   sut = SimpleMQTTClient.new 'ltg.evl.uic.edu'
  #   sut.publish('demo4/demo5/demo6', 'test-message-3')
  #   # Make sure we wait for the message to be delivered
  #   sleep(1)
  #   assert_equal total, 6
  # end

  # Private methods

  # def test_build_regex_from_pattern
  #   skip
  # end


  # def test_matches_wildcard_pattern
  #   skip
  # end


  # def test_wildcard_regex
  #   MQTT::Client.stub :connect, MQTT::Client.new do
  #     sut = SimpleMQTTClient.new 'localhost'      
  #     # Multi-level
  #     assert sut.send :matches_wildcard_pattern, '/any/channel', '#'
  #     assert sut.send :matches_wildcard_pattern, 'any/channel', '#'
  #     assert sut.send :matches_wildcard_pattern, '', '#'
  #     assert sut.send :matches_wildcard_pattern, '/a/channel', '/a/#'
  #     # One single-level
  #     assert sut.send :matches_wildcard_pattern, 'a_channel', '+'
  #     assert sut.send :matches_wildcard_pattern, '/a_channel', '/+'
  #     assert sut.send :matches_wildcard_pattern, 'a/channel', 'a/+'
  #     assert sut.send :matches_wildcard_pattern, 'a/channel', '+/channel'
  #     assert sut.send :matches_wildcard_pattern, '/a/channel', '/+/channel'
  #     assert sut.send :matches_wildcard_pattern, '/a/channel/yup', '/a/+/yup'
  #     # Two single-level
  #     assert sut.send :matches_wildcard_pattern, 'a/channel', '+/+'
  #     assert sut.send :matches_wildcard_pattern, '/a/channel', '/+/+'
  #     assert sut.send :matches_wildcard_pattern, '/a/channel/yup', '/+/+/yup'
  #     # Mix, Multi-level, one single level
  #     assert sut.send :matches_wildcard_pattern, '/a/channel/yup', '/+/channel/#'
  #     # Mix, Multi-level, two single level
  #     assert sut.send :matches_wildcard_pattern, '/a/channel/yup/another', '/+/+/yup/#'
  #   end
  # end

