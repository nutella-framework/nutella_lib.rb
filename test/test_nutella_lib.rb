require 'helper'

class TestNutellaLib < MiniTest::Test


  # def test_connect_and_send_receive_messages_correctly
  #   cb_executed = false
  #   nutella.init('my_run_id', 'ltg.evl.uic.edu', 'my_bot_component')
  #   nutella.set_resource_id 'my_resource_id'
  #   cb = lambda do |message, component_id, resource_id|
  #     cb_executed = true
  #     puts "Received message from #{component_id}/#{resource_id}. Message: #{message}"
  #   end
  #   nutella.net.subscribe('demo1', cb)
  #   sleep 1
  #   nutella.net.publish('demo1', 'test_message')
  #   # Make sure we wait for the message to be delivered
  #   sleep 1
  #   assert cb_executed
  # end
  #
  #
  # def test_connect_and_send_receive_wildcard_messages_correctly
  #   cb_executed = false
  #   nutella.init('my_run_id', 'ltg.evl.uic.edu', 'my_bot_component')
  #   nutella.set_resource_id 'my_resource_id'
  #   cb = lambda do |message, channel, component_id, resource_id|
  #     cb_executed = true
  #     puts "Received message on #{channel} from #{component_id}/#{resource_id}. Message: #{message}"
  #   end
  #   nutella.net.subscribe('demo1/#', cb)
  #   sleep 1
  #   nutella.net.publish('demo1/demo', 'test_message')
  #   # Make sure we wait for the message to be delivered
  #   sleep 1
  #   assert cb_executed
  # end


  # def test_multiple_subscriptions
  #   nutella.init('my_run_id', 'ltg.evl.uic.edu', 'my_bot_component')
  #   nutella.set_resource_id 'my_resource_id'
  #   cb = lambda do |message, component_id, resource_id|
  #     puts "Received message #{component_id}/#{resource_id}. Message: #{message}"
  #   end
  #   nutella.net.subscribe('demo1', cb)
  #   nutella.net.subscribe('demo1', cb) # This must raise an error
  # end


  # def test_request_response
  #   nutella.init('my_run_id', 'ltg.evl.uic.edu', 'my_bot_component')
  #   nutella.set_resource_id 'my_resource_id'
  #
  #   nutella.net.subscribe('demo1', lambda do |message, component_id, resource_id|
  #     puts "Received a message from #{component_id}/#{resource_id}. Message: #{message}"
  #   end)
  #
  #   nutella.net.handle_requests( 'demo1', lambda do |message, component_id, resource_id|
  #     puts "We received a request: message #{message}, from #{component_id}/#{resource_id}"
  #     #Then we are going to return some JSON
  #     {my:'json'}
  #   end)
  #
  #   response = nutella.net.sync_request( 'demo1', 'my request is a string' )
  #   puts 'Response to sync'
  #   p response
  #
  #   nutella.net.async_request( 'demo1', 'my request is a string', lambda do |response|
  #     puts 'Response to async'
  #     p response
  #   end)
  #
  #   nutella.net.listen
  # end


end
