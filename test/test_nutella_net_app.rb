require 'helper'

class TestNutellaNetApp < MiniTest::Test

  # nutella.init_as_app_component('localhost', 'my_app_id', 'my_component_id')
  #
  # def test_app_send_receive
  #   cb_executed = false
  #   cb = lambda do |message, from|
  #     cb_executed = true
  #     puts "Received message from #{from['component_id']}/#{from['resource_id']}. Message: #{message}"
  #   end
  #   nutella.net.app.subscribe('demo0', cb)
  #   sleep 1
  #   nutella.net.app.publish('demo0', 'test_message')
  #   # Make sure we wait for the message to be delivered
  #   sleep 1
  #   assert cb_executed
  # end
  #
  #
  # def test_app_send_receive_wildcard
  #   cb_executed = false
  #   nutella.set_resource_id 'my_resource_id_1'
  #   cb = lambda do |message, channel, from|
  #     cb_executed = true
  #     puts "Received message on #{channel} from #{from['component_id']}/#{from['resource_id']}. Message: #{message}"
  #   end
  #   nutella.net.app.subscribe('demo1/#', cb)
  #   sleep 1
  #   nutella.net.app.publish('demo1/demo', 'test_message')
  #   # Make sure we wait for the message to be delivered
  #   sleep 1
  #   assert cb_executed
  # end
  #
  #
  # def test_multiple_subscriptions
  #   nutella.set_resource_id 'my_resource_id_2'
  #   cb = lambda do |message, from|
  #     puts "Received message #{from['component_id']}/#{from['resource_id']}. Message: #{message}"
  #   end
  #   assert_raises RuntimeError do
  #     nutella.net.app.subscribe('demo2', cb)
  #     nutella.net.app.subscribe('demo2', cb)
  #   end
  #   nutella.net.app.unsubscribe('demo2')
  #   nutella.net.app.subscribe('demo2', cb)
  # end
  #
  #
  # def test_request_response
  #   nutella.set_resource_id 'my_resource_id_3'
  #
  #   nutella.net.app.subscribe('demo3', lambda do |message, from|
  #     puts "Received a message from #{from['component_id']}/#{from['resource_id']}. Message: #{message}"
  #   end)
  #
  #   nutella.net.app.handle_requests( 'demo3', lambda do |message, from|
  #     puts "We received a request: message #{message}, from #{from['component_id']}/#{from['resource_id']}."
  #     #Then we are going to return some random JSON
  #     {my:'json'}
  #   end)
  #
  #   response = nutella.net.app.sync_request( 'demo3', 'my request is a string' )
  #   assert_equal({'my' => 'json'}, response)
  #
  #   nutella.net.app.async_request( 'demo3', 'my request is a string', lambda do |response|
  #     assert_equal({'my' => 'json'}, response)
  #   end)
  #
  #   sleep(2)
  # end
  #
  # def test_app_run_pub_sub_all
  #   nutella.set_resource_id 'my_resource_id_5'
  #   cb = lambda do |message, run_id, from|
  #     puts "Received message from run_id #{from['run_id']} on #{run_id}. Message: #{message}"
  #     nutella.net.app.unsubscribe_from_all_runs 'demo5'
  #   end
  #   nutella.net.app.subscribe_to_all_runs('demo5', cb)
  #   sleep 1
  #   nutella.net.app.publish_to_all_runs('demo5', 'test_message')
  #   # Make sure we wait for the message to be delivered
  #   sleep 2
  # end
  #
  # def test_app_run_req_res_all
  #   nutella.set_resource_id 'my_resource_id_6'
  #
  #   nutella.net.app.handle_requests_on_all_runs('demo6', lambda do |message, run_id, from|
  #     puts "We received a request: message '#{message}', on run_id #{run_id} from #{from}."
  #     'response' # Return something
  #   end)
  #   sleep 1
  #   nutella.net.app.async_request_to_all_runs('demo6', 'my request is a string', lambda do |response|
  #     puts response
  #   end)
  #   sleep 2
  # end

  # TODO do more tests for app to run APIs and broadcasting

end