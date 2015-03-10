require 'helper'

class TestNutellaNet < MiniTest::Test


  # def test_send_receive
  #   nutella.init('localhost', 'my_app_id', 'my_run_id' , 'my_component_id')
  #   cb_executed = false
  #   cb = lambda do |message, from|
  #     cb_executed = true
  #     puts "Received message from #{from['component_id']}/#{from['resource_id']}. Message: #{message}"
  #   end
  #   nutella.net.subscribe('demo0', cb)
  #   sleep 1
  #   nutella.net.publish('demo0', 'test_message')
  #   # Make sure we wait for the message to be delivered
  #   sleep 1
  #   assert cb_executed
  # end
  #
  #
  # def test_send_receive_wildcard
  #   cb_executed = false
  #   nutella.init('localhost', 'my_app_id', 'my_run_id' , 'my_component_id')
  #   nutella.set_resource_id 'my_resource_id_1'
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
  #
  #
  # def test_multiple_subscriptions
  #   nutella.init('localhost', 'my_app_id', 'my_run_id' , 'my_component_id')
  #   nutella.set_resource_id 'my_resource_id_2'
  #   cb = lambda do |message, from|
  #     puts "Received message #{from['component_id']}/#{from['resource_id']}. Message: #{message}"
  #   end
  #   assert_raises RuntimeError do
  #     nutella.net.subscribe('demo2', cb)
  #     nutella.net.subscribe('demo2', cb)
  #   end
  #   nutella.net.unsubscribe('demo2')
  #   nutella.net.subscribe('demo2', cb)
  # end
  #
  #
  # def test_request_response
  #   nutella.init('localhost', 'my_app_id', 'my_run_id' , 'my_component_id')
  #   nutella.set_resource_id 'my_resource_id_3'
  #
  #   nutella.net.subscribe('demo3', lambda do |message, from|
  #     puts "Received a message from #{from['component_id']}/#{from['resource_id']}. Message: #{message}"
  #   end)
  #
  #   nutella.net.handle_requests( 'demo3', lambda do |message, from|
  #     puts "We received a request: message #{message}, from #{from['component_id']}/#{from['resource_id']}."
  #     #Then we are going to return some random JSON
  #     {my:'json'}
  #   end)
  #
  #   response = nutella.net.sync_request( 'demo3', 'my request is a string' )
  #   assert_equal({'my' => 'json'}, response)
  #
  #   nutella.net.async_request( 'demo3', 'my request is a string', lambda do |response|
  #     assert_equal({'my' => 'json'}, response)
  #   end)
  #
  #   sleep(2)
  # end


end