module Nutella

  # This class implements the pub/sub and request/response nutella protocol
  module Net

    # Store the subscriptions and the relative callbacks
    @subscriptions = []
    @callbacks = []

    # Sub-modules loading
    def self.app; Nutella::Net::App end


    # Subscribe to a channel or to a set of channels.
    #
    # @param [String] channel the channel or filter we are subscribing to. This can
    #   contain wildcard characters.
    # @param [Proc] callback a lambda expression that takes as parameters:
    # - [String] the received message. Messages that are not JSON are discarded.
    # - [String][optional] the channel the message was received on (only for wildcard subscriptions)
    # - [Hash] the sender's identifiers (run_id, app_id, component_id and optionally resource_id)
    def Net.subscribe (channel, callback)
      # Maintain unique subscriptions
      raise 'You can`t subscribe twice to the same channel`' if @subscriptions.include? channel
      # Depending on what type of channel we are subscribing to (wildcard or simple)
      # register a different kind of callback
      if Nutella.mqtt.is_channel_wildcard?(channel)
        mqtt_cb = lambda do |mqtt_message, mqtt_channel|
          begin
            type, from, payload, _ = extract_fields_from_message mqtt_message
            callback.call(payload, un_pad_run_ch(mqtt_channel), from) if type=='publish'
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
      @subscriptions.push channel
      @callbacks.push mqtt_cb
      Nutella.mqtt.subscribe( pad_to_run_ch(channel), mqtt_cb )
    end


    # Unsubscribe from a channel

    # @param [String] channel we want to unsubscribe from. Can contain wildcards.
    def Net.unsubscribe(channel)
      idx = @subscriptions.index channel
      # If we are not subscribed to this channel, return (no error is given)
      return if idx.nil?
      # Fetch the mqtt_callback associated with this channel/subscription
      mqtt_cb = @callbacks[idx]
      # Remove from subscriptions, callbacks and unsubscribe
      @subscriptions.delete_at idx
      @callbacks.delete_at idx
      Nutella.mqtt.unsubscribe( pad_to_run_ch(channel), mqtt_cb )
    end


    # Publishes a message to a channel
    # Message can be:
    # - nil/empty
    # - a string
    # - a hash
    # - some JSON
    def Net.publish(channel, message=nil)
      # Throw exception if trying to publish something that is not JSON
      begin
        m = Net.prepare_message_for_publish message
        Nutella.mqtt.publish( pad_to_run_ch(channel), m )
      rescue
        STDERR.puts 'Error: you are trying to publish something that is not JSON'
      end
    end


    # Performs a synchronous request
    # Message can be:
    # - nil/empty
    # - a string
    # - a hash
    # - some JSON
    def Net.sync_request ( channel, message=nil )
      # Pad channel
      padded_ch = pad_to_run_ch(channel)
      # Prepare message
      m, id = prepare_message_for_request message
      # Initialize response
      response = nil
      # Prepare callback
      mqtt_cb = lambda do |mqtt_message|
        type, _, payload, m_id = extract_fields_from_message mqtt_message
        if m_id==id && type=='response'
          response = payload
          Nutella.mqtt.unsubscribe( padded_ch, mqtt_cb )
        end
      end
      # Subscribe
      Nutella.mqtt.subscribe( padded_ch, mqtt_cb )
      # Publish message
      Nutella.mqtt.publish( padded_ch, m )
      # Wait for the response to come back
      sleep(0.1) while response.nil?
      response
    end


    # Performs an asynchronous request
    # Message can be:
    # empty (equivalent of a GET)
    # string (the string will be wrapped into a JSON string automatically. Format: {"payload":"<message>"})
    # hash (the hash will be converted into a JSON string automatically)
    # json string (the JSON string will be sent as is)
    def Net.async_request ( channel, message=nil, callback )
      # Pad channel
      padded_ch = pad_to_run_ch(channel)
      # Prepare message
      m, id = prepare_message_for_request message
      # Prepare callback
      mqtt_cb = lambda do |mqtt_message|
        type, _, payload, m_id = extract_fields_from_message mqtt_message
        if m_id==id && type=='response'
          callback.call(payload)
          Nutella.mqtt.unsubscribe( padded_ch, mqtt_cb )
        end
      end
      # Subscribe
      Nutella.mqtt.subscribe( padded_ch, mqtt_cb )
      # Publish message
      Nutella.mqtt.publish( padded_ch, m )
    end


    # Handle requests
    def Net.handle_requests( channel, callback )
      # Pad the channel
      padded_ch = pad_to_run_ch(channel)
      mqtt_cb = lambda do |request|
        begin
          # Extract nutella fields
          type, from, payload, id = extract_fields_from_message request
          # Only handle requests that have proper id set
          return if type!='request' || id.nil?
          m = Net.prepare_message_for_response( callback.call( payload, from), id )
          Nutella.mqtt.publish( padded_ch, m )
          # Assemble the response and check that it's proper JSON
        rescue JSON::ParserError
          # Make sure that request contains JSON, if not drop the message
          return
        rescue
          # Check that the passed callback has the right number of arguments
          STDERR.puts "The callback you passed to subscribe has the #{$!}: it needs 'payload' and 'from'"
        end
      end
      # Subscribe to the channel
      Nutella.mqtt.subscribe(padded_ch, mqtt_cb)
    end


    # Listens for incoming messages
    def Net.listen
      begin
        sleep
      rescue Interrupt
        # Simply returns
      end
    end


    private


    def Net.extract_fields_from_message(message)
      mh = JSON.parse message
      return mh['type'], mh['from'], mh['payload'], mh['id']
    end

    def Net.pad_to_app_ch( channel )
      "/nutella/apps/#{Nutella.app_id}/#{channel}"
    end

    def Net.pad_to_run_ch( channel )
      "/nutella/apps/#{Nutella.app_id}/runs/#{Nutella.run_id}/#{channel}"
    end

    def Net.un_pad_run_ch( channel )
      channel.gsub("/nutella/apps/#{Nutella.app_id}/runs/#{Nutella.run_id}/", '')
    end

    def Net.assemble_from
      from = Hash.new
      if Nutella.run_id.nil?
        from['type'] = 'app'
      else
        from['type'] = 'run'
        from['run_id'] = Nutella.run_id
      end
      from['app_id'] = Nutella.app_id
      from['component_id'] = Nutella.component_id
      from['resource_id'] = Nutella.resource_id unless Nutella.resource_id.nil?
      from
    end

    def Net.prepare_message_for_publish( message )
      if message.nil?
        return {type: 'publish', from: assemble_from}.to_json
      end
      {type: 'publish', from: assemble_from, payload: message}.to_json
    end

    def Net.prepare_message_for_request( message )
      if message.nil?
        return {id: message.hash, type: 'request', from: assemble_from}.to_json, message.hash
      end
      return {id: message.hash, type: 'request', from: assemble_from, payload: message}.to_json, message.hash
    end

    def Net.prepare_message_for_response( message, id )
      if message.nil?
        return {id: id, type: 'response', from: assemble_from}.to_json
      end
      {id: id, type: 'response', from: assemble_from, payload: message}.to_json
    end

  end
end