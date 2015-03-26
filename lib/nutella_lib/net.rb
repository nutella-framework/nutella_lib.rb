module Nutella

  # This module implements the pub/sub and request/response APIs at the run level
  module Net

    # Store the subscriptions and the relative callbacks
    @subscriptions = []
    @callbacks = []

    # Provides access to the subscriptions
    def self.subscriptions; @subscriptions end

    # Provides access to callbacks
    def self.callbacks; @callbacks end


    # Subscribes to a channel or to a set of channels.
    #
    # @param [String] channel the channel or filter we are subscribing to. Can contain wildcard(s)
    # @param [Proc] callback a lambda expression that is fired whenever a message is received.
    #   The passed callback takes the following parameters:
    #   - [String] message: the received message. Messages that are not JSON are discarded.
    #   - [String] channel: the channel the message was received on (optional, only for wildcard subscriptions)
    #   - [Hash] from: the sender's identifiers (run_id, app_id, component_id and optionally resource_id)
    def self.subscribe( channel, callback )
      subscribe_to( channel, callback, Nutella.app_id, Nutella.run_id)
    end


    # Un-subscribes from a channel
    #
    # @param [String] channel we want to unsubscribe from. Can contain wildcard(s).
    def self.unsubscribe( channel )
      unsubscribe_to( channel, Nutella.app_id, Nutella.run_id)
    end


    # Publishes a message to a channel
    #
    # @param [String] channel we want to publish the message to. *CANNOT* contain wildcard(s)!
    # @param [Object] message the message we are publishing. This can be,
    #   nil/empty (default), a string, a hash and, in general, anything with a .to_json method.
    def self.publish( channel, message=nil )
      publish_to( channel, message, Nutella.app_id, Nutella.run_id)
    end


    # Performs a synchronous request.
    #
    # @param [String] channel we want to make the request to. *CANNOT* contain wildcard(s)!
    # @param [Object] message the body of request. This can be,
    #   nil/empty (default), a string, a hash and, in general, anything with a .to_json method.
    def self.sync_request( channel, message=nil )
      sync_request_to(channel, message, Nutella.app_id, Nutella.run_id)
    end


    # Performs an asynchronous request
    #
    # @param [String] channel we want to make the request to. *CANNOT* contain wildcard(s)!
    # @param [Object] message the body of request. This can be,
    #   nil/empty (default), a string, a hash and, in general, anything with a .to_json method.
    # @param [Proc] callback the callback that is fired whenever a response is received. It takes one parameter (response).
    def self.async_request( channel, message=nil, callback )
      async_request_to(channel, message, callback, Nutella.app_id, Nutella.run_id)
    end


    # Handles requests on a certain channel
    #
    # @param [String] channel we want to listen for requests on. Can contain wildcard(s).
    # @param [Proc] callback a lambda expression that is fired whenever a message is received.
    #   The passed callback takes the following parameters:
    #   - [String] the received message (payload). Messages that are not JSON are discarded.
    #   - [Hash] the sender's identifiers (run_id, app_id, component_id and optionally resource_id)
    #   - [*returns* Hash] The response sent back to the client that performed the request. Whatever is returned by the callback is marshaled into a JSON string and sent via MQTT.
    #
    def self.handle_requests( channel, callback )
      handle_requests_on(channel, callback, Nutella.app_id, Nutella.run_id)
    end


    # Listens for incoming messages. All this function
    # does is to put the thread to sleep and wait for something to
    # happen over the network to wake up.
    def self.listen
      begin
        sleep
      rescue Interrupt
        # Simply returns once interrupted
      end
    end


    private


    def self.extract_fields_from_message(message)
      mh = JSON.parse message
      return mh['type'], mh['from'], mh['payload'], mh['id']
    end

    def self.pad_channel( channel, app_id, run_id )
      raise 'If the run_id is specified, app_id needs to also be specified' if (!run_id.nil? && app_id.nil?)
      return "/nutella/#{channel}" if (app_id.nil? && run_id.nil?)
      return "/nutella/apps/#{app_id}/#{channel}" if (!app_id.nil? && run_id.nil?)
      "/nutella/apps/#{app_id}/runs/#{run_id}/#{channel}"
    end

    def self.un_pad_channel( channel, app_id, run_id )
      raise 'If the run_id is specified, app_id needs to also be specified' if (!run_id.nil? && app_id.nil?)
      return channel.gsub('/nutella/', '') if (app_id.nil? && run_id.nil?)
      return channel.gsub("/nutella/apps/#{app_id}/", '') if (!app_id.nil? && run_id.nil?)
      channel.gsub("/nutella/apps/#{app_id}/runs/#{run_id}/", '')
    end

    def self.assemble_from
      from = Hash.new
      if Nutella.run_id.nil?
        if Nutella.app_id.nil?
          from['type'] = 'framework'
        else
          from['type'] = 'app'
          from['app_id'] = Nutella.app_id
        end
      else
        from['type'] = 'run'
        from['run_id'] = Nutella.run_id
      end
      from['component_id'] = Nutella.component_id
      from['resource_id'] = Nutella.resource_id unless Nutella.resource_id.nil?
      from
    end

    def self.prepare_message_for_publish( message )
      if message.nil?
        return {type: 'publish', from: assemble_from}.to_json
      end
      {type: 'publish', from: assemble_from, payload: message}.to_json
    end

    def self.prepare_message_for_request( message )
      id = message.hash + Random.rand(100)
      if message.nil?
        return {id: id, type: 'request', from: assemble_from}.to_json, id
      end
      return {id: id, type: 'request', from: assemble_from, payload: message}.to_json, id
    end

    def self.prepare_message_for_response( message, id )
      if message.nil?
        return {id: id, type: 'response', from: assemble_from}.to_json
      end
      {id: id, type: 'response', from: assemble_from, payload: message}.to_json
    end


    # Subscribes to a channel or to a set of channels.
    #
    # @param [String] channel the channel or filter we are subscribing to. Can contain wildcard(s)
    # @param [Proc] callback a lambda expression that is fired whenever a message is received.
    #   The passed callback takes the following parameters:
    #   - [String] message: the received message. Messages that are not JSON are discarded.
    #   - [String] channel: the channel the message was received on (optional, only for wildcard subscriptions)
    #   - [Hash] from: the sender's identifiers (run_id, app_id, component_id and optionally resource_id)
    # @param [String] app_id used to pad channels
    # @param [String] run_id used to pad channels
    def self.subscribe_to( channel, callback, app_id, run_id )
      # Check the passed callback has the right number of arguments
      if Nutella.mqtt.is_channel_wildcard?(channel)
        raise 'You need to pass a callback with 3 parameters (message, channel, from) when subscribing to a wildcard channel!' if callback.parameters.length!=3
      else
        raise 'You need to pass a callback with 2 parameters (message, from) when subscribing to a channel!' if callback.parameters.length!=2
      end
      # Pad channel
      padded_channel = pad_channel(channel, app_id, run_id)
      # Maintain unique subscriptions
      raise 'You can`t subscribe twice to the same channel`' if @subscriptions.include? padded_channel
      # Depending on what type of channel we are subscribing to (wildcard or simple)
      # register a different kind of callback
      if Nutella.mqtt.is_channel_wildcard?(padded_channel)
        mqtt_cb = lambda do |mqtt_message, mqtt_channel|
          begin
            type, from, payload, _ = extract_fields_from_message mqtt_message
            callback.call(payload, un_pad_channel(mqtt_channel, app_id, run_id), from) if type=='publish'
          rescue JSON::ParserError
            # Make sure the message is JSON, if not drop the message
            return
          rescue
            # Check the passed callback has the right number of arguments
            STDERR.puts "The callback you passed to subscribe has the #{$!}: it needs 'payload', 'channel' and 'from'"
          end
        end
      else
        mqtt_cb = lambda do |message|
          begin
            type, from, payload, _ = extract_fields_from_message message
            callback.call(payload, from)  if type=='publish'
          rescue JSON::ParserError
            # Make sure the message is JSON, if not drop the message
            return
          rescue
            # Check the passed callback has the right number of arguments
            STDERR.puts "The callback you passed to subscribe has the #{$!}: it needs 'payload' and 'from'"
          end
        end
      end
      # Add to subscriptions, save mqtt callback and subscribe
      @subscriptions.push padded_channel
      @callbacks.push mqtt_cb
      Nutella.mqtt.subscribe( padded_channel, mqtt_cb )
      # Notify subscriptions bot
      publish_to('subscriptions', {'channel' => padded_channel}, app_id, run_id)
    end


    # Un-subscribes from a channel
    #
    # @param [String] channel we want to unsubscribe from. Can contain wildcard(s).
    # @param [String] app_id used to pad channels
    # @param [String] run_id used to pad channels
    def self.unsubscribe_to( channel, app_id, run_id )
      # Pad channel
      padded_channel = pad_channel(channel, app_id, run_id)
      idx = @subscriptions.index padded_channel
      # If we are not subscribed to this channel, return (no error is given)
      return if idx.nil?
      # Fetch the mqtt_callback associated with this channel/subscription
      mqtt_cb = @callbacks[idx]
      # Remove from subscriptions, callbacks and unsubscribe
      @subscriptions.delete_at idx
      @callbacks.delete_at idx
      Nutella.mqtt.unsubscribe( padded_channel, mqtt_cb )
    end


    # Publishes a message to a channel
    #
    # @param [String] channel we want to publish the message to. *CANNOT* contain wildcard(s)!
    # @param [Object] message the message we are publishing. This can be,
    #   nil/empty (default), a string, a hash and, in general, anything with a .to_json method.
    # @param [String] app_id used to pad channels
    # @param [String] run_id used to pad channels
    def self.publish_to( channel, message=nil, app_id, run_id )
      # Pad channel
      padded_channel = pad_channel(channel, app_id, run_id)
      # Throw exception if trying to publish something that is not JSON
      begin
        m = self.prepare_message_for_publish message
        Nutella.mqtt.publish( padded_channel, m )
      rescue
        STDERR.puts 'Error: you are trying to publish something that is not JSON'
        STDERR.puts $!
      end
    end


    # Performs a synchronous request.
    #
    # @param [String] channel we want to make the request to. *CANNOT* contain wildcard(s)!
    # @param [Object] message the body of request. This can be,
    #   nil/empty (default), a string, a hash and, in general, anything with a .to_json method.
    # @param [String] app_id used to pad channels
    # @param [String] run_id used to pad channels
    def self.sync_request_to( channel, message=nil, app_id, run_id )
      # Pad channel
      padded_channel = pad_channel(channel, app_id, run_id)
      # Prepare message
      m, id = prepare_message_for_request message
      # Initialize response
      response = nil
      # Prepare callback
      mqtt_cb = lambda do |mqtt_message|
        type, _, payload, m_id = extract_fields_from_message mqtt_message
        if m_id==id && type=='response'
          response = payload
          Nutella.mqtt.unsubscribe( padded_channel, mqtt_cb )
        end
      end
      # Subscribe
      Nutella.mqtt.subscribe( padded_channel, mqtt_cb )
      # Publish message
      Nutella.mqtt.publish( padded_channel, m )
      # Wait for the response to come back
      sleep(0.1) while response.nil?
      response
    end


    # Performs an asynchronous request
    #
    # @param [String] channel we want to make the request to. *CANNOT* contain wildcard(s)!
    # @param [Object] message the body of request. This can be,
    #   nil/empty (default), a string, a hash and, in general, anything with a .to_json method.
    # @param [Proc] callback the callback that is fired whenever a response is received. It takes one parameter (response).
    # @param [String] app_id used to pad channels
    # @param [String] run_id used to pad channels
    def self.async_request_to( channel, message=nil, callback, app_id, run_id )
      # Check the passed callback has the right number of arguments
      raise 'You need to pass a callback with 1 parameter (response) when making an asynchronous request!' if callback.parameters.length!=1
      # Pad channel
      padded_channel = pad_channel(channel, app_id, run_id)
      # Prepare message
      m, id = prepare_message_for_request message
      # Prepare callback
      mqtt_cb = lambda do |mqtt_message|
        type, _, payload, m_id = extract_fields_from_message mqtt_message
        if m_id==id && type=='response'
          callback.call(payload)
          Nutella.mqtt.unsubscribe( padded_channel, mqtt_cb )
        end
      end
      # Subscribe
      Nutella.mqtt.subscribe( padded_channel, mqtt_cb )
      # Publish message
      Nutella.mqtt.publish( padded_channel, m )
    end


    # Handles requests on a certain channel
    #
    # @param [String] channel we want to listen for requests on. Can contain wildcard(s).
    # @param [Proc] callback a lambda expression that is fired whenever a message is received.
    #   The passed callback takes the following parameters:
    #   - [String] the received message (payload). Messages that are not JSON are discarded.
    #   - [Hash] the sender's identifiers (run_id, app_id, component_id and optionally resource_id)
    #   - [*returns* Hash] The response sent back to the client that performed the request. Whatever is returned by the callback is marshaled into a JSON string and sent via MQTT.
    # @param [String] app_id used to pad channels
    # @param [String] run_id used to pad channels
    def self.handle_requests_on( channel, callback, app_id, run_id )
      # Check the passed callback has the right number of arguments
      raise 'You need to pass a callback with 2 parameter (request, from) when handling requests!' if callback.parameters.length!=2
      # Pad channel
      padded_channel = pad_channel(channel, app_id, run_id)
      mqtt_cb = lambda do |request|
        begin
          # Extract nutella fields
          type, from, payload, id = extract_fields_from_message request
          # Only handle requests that have proper id set
          return if type!='request' || id.nil?
          # Execute callback and send response
          m = self.prepare_message_for_response( callback.call( payload, from), id )
          Nutella.mqtt.publish( padded_channel, m )
        rescue JSON::ParserError
          # Make sure that request contains JSON, if not drop the message
          return
        rescue
          # Check that the passed callback has the right number of arguments
          STDERR.puts "The callback you passed to subscribe has the #{$!}: it needs 'payload' and 'from'"
        end
      end
      # Subscribe to the channel
      Nutella.mqtt.subscribe(padded_channel, mqtt_cb)
    end
  end
end