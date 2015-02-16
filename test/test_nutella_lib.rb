require 'helper'

class TestNutellaLib < MiniTest::Test


  def test_connect_and_send_receive_messages_correctly
    cb_executed = false
    nutella.init('my_run_id', 'ltg.evl.uic.edu', 'my_bot_component')
    nutella.set_resource_id 'my_resource_id'
    cb = lambda do |message, component_id, resource_id|
      cb_executed = true
      puts "Received message from #{component_id}/#{resource_id}. Message: #{message}"
    end
    nutella.net.subscribe('demo1', cb)
    sleep 1
    nutella.net.publish('demo1', 'test_message')
    # Make sure we wait for the message to be delivered
    sleep 1
    assert cb_executed
  end


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
  # def test_recognize_wildcard_patters_correctly
  #   sc4 = SimpleMQTTClient.new 'ltg.evl.uic.edu'
  #   sc4.subscribe('run_id/#', lambda {|m| puts m})
  #   refute_nil sc4.send(:get_callbacks, 'run_id/one')
  #   refute_nil sc4.send(:get_callbacks, 'run_id/one/two')
  # end
  #
  #  def test_multiple_subscriptions
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


end
