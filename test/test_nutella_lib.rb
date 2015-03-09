require 'helper'

class TestNutellaLib < MiniTest::Test


  # def test_connect_and_send_receive_messages_correctly
  #   nutella.init('localhost', 'my_app_id', 'my_run_id' , 'my_component_id')
  #   cb_executed = false
  #   nutella.set_resource_id 'my_resource_id'
  #   cb = lambda do |message, from|
  #     cb_executed = true
  #     puts "Received message from #{from['component_id']}/#{from['resource_id']}. Message: #{message}"
  #   end
  #   nutella.net.subscribe('demo1', cb)
  #   sleep 1
  #   nutella.net.publish('demo1', 'test_message')
  #   # Make sure we wait for the message to be delivered
  #   sleep 1
  #   assert cb_executed
  # end


  # def test_connect_and_receive_wildcard_messages_correctly
  #   cb_executed = false
  #   nutella.init('localhost', 'my_app_id', 'my_run_id' , 'my_component_id')
  #   nutella.set_resource_id 'my_resource_id'
  #   cb = lambda do |message, channel, from|
  #     cb_executed = true
  #     puts "Received message on #{channel} from #{from['component_id']}/#{from['resource_id']}. Message: #{message}"
  #   end
  #   nutella.net.subscribe('demo1/#', cb)
  #   sleep 1
  #   nutella.net.publish('demo1/demo', 'test_message')
  #   # Make sure we wait for the message to be delivered
  #   sleep 1
  #   assert cb_executed
  # end


  # def test_multiple_subscriptions
  #   nutella.init('localhost', 'my_app_id', 'my_run_id' , 'my_component_id')
  #   nutella.set_resource_id 'my_resource_id'
  #   cb = lambda do |message, from|
  #     puts "Received message #{from['component_id']}/#{from['resource_id']}. Message: #{message}"
  #   end
  #   nutella.net.subscribe('demo1', cb)
  #   nutella.net.subscribe('demo1', cb) # This must raise an error
  # end


  # def test_request_response
  #   nutella.init('localhost', 'my_app_id', 'my_run_id' , 'my_component_id')
  #   nutella.set_resource_id 'my_resource_id'
  #
  #   nutella.net.subscribe('demo1', lambda do |message, from|
  #     puts "Received a message from #{from['component_id']}/#{from['resource_id']}. Message: #{message}"
  #   end)
  #
  #   nutella.net.handle_requests( 'demo1', lambda do |message, from|
  #     puts "We received a request: message #{message}, from #{from['component_id']}/#{from['resource_id']}."
  #     #Then we are going to return some random JSON
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
