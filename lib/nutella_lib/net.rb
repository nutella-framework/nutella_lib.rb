module Nutella

  # This class implements the pub/sub and request/response nutella protocol
  # @author Alessandro Gnoli <tebemis@gmail.com>
  module Net

    # Store the subscriptions and the relative callbacks
    @subscriptions = []
    @callbacks = []

    # Subscribe to a channel or to a set of channels if using wildcards
    #
    # @param [String] channel the channel we are subscribing to, can be wildcard
    # @param [Proc] callback a lambda expression that takes as parameters:
    # - the received message. Messages that are not JSON are discarded.
    # - the channel the message was received on (in case of wildcard subscription)
    # - the sender's component_id
    # - the sender's resource_id (if set by the sender)
    def Net.subscribe (channel, callback)
      # Maintain unique subscriptions
      raise 'You can`t subscribe twice to the same channel`' if @subscriptions.include? channel
      # Pad the channel
      new_channel = "#{Nutella.run_id}/#{channel}"
      # Depending on what type of channel we are subscribing to (wildcard or simple)
      # register a different kind of callback
      if Nutella.mqtt.is_channel_wildcard?(channel)
        mqtt_cb = lambda do |message, channel|
          # Make sure the message is JSON, if not drop the message
          begin
            channel.slice!("#{Nutella.run_id}/")
            type, payload, component_id, resource_id = extract_nutella_fields_from_message message
            callback.call(payload, channel, component_id, resource_id) if type=='publish'
          rescue
            return
          end
        end
      else
        mqtt_cb = lambda do |message|
          # Make sure the message is JSON, if not drop the message
          begin
            type, payload, component_id, resource_id = extract_nutella_fields_from_message message
            callback.call(payload, component_id, resource_id)  if type=='publish'
          rescue
            return
          end
        end
      end
      # Subscribe
      @subscriptions.push channel
      @callbacks.push mqtt_cb
      Nutella.mqtt.subscribe(new_channel, mqtt_cb)
    end


    # Unsubscribe from a channel
    def Net.unsubscribe(channel)
      idx = @subscriptions.index channel
      # If we are not subscribed to this channel, return (no error is given)
      return if idx.nil?
      # Pad the channel
      mqtt_cb = @callbacks[idx]
      new_channel = Nutella.run_id + '/' + channel
      # Unsubscribe
      @subscriptions.delete_at idx
      @callbacks.delete_at idx
      Nutella.mqtt.unsubscribe( new_channel, mqtt_cb )
    end


    # Publishes a message to a channel
    # Message can be:
    # empty (equivalent of a GET)
    # string (the string will be wrapped into a JSON string automatically. Format: {"payload":"<message>"})
    # hash (the hash will be converted into a JSON string automatically)
    # json string (the JSON string will be sent as is)
    def Net.publish(channel, message=nil)
      # Pad the channel
      new_channel = Nutella.run_id + '/' + channel
      # Publish
      begin
        m = Net.prepare_message_for_publish(message)
        Nutella.mqtt.publish(new_channel, m)
      rescue
        STDERR.puts $!
      end
    end


    # Performs a synchronous request
    # Message can be:
    # empty (equivalent of a GET)
    # string (the string will be wrapped into a JSON string automatically. Format: {"payload":"<message>"})
    # hash (the hash will be converted into a JSON string automatically)
    # json string (the JSON string will be sent as is)
    def Net.sync_req (channel, message=nil)
      # Pad channel
      new_channel = "#{Nutella.run_id}/#{channel}"
      # Prepare message
      m, id = prepare_message_for_request message
      # Initialize response
      response = nil
      # Prepare callback
      mqtt_cb = lambda do |message|
        m_id = extract_id_from_message message
        type, payload  = extract_nutella_fields_from_response message
        if m_id==id && type=='response'
          response = payload
          Nutella.mqtt.unsubscribe( new_channel, mqtt_cb )
        end
      end
      # Subscribe
      Nutella.mqtt.subscribe( new_channel, mqtt_cb )
      # Publish message
      Nutella.mqtt.publish( new_channel, m )
      # Wait for the response to come back
      sleep(0.1) while response.nil?
      response
    end


    # Performs an asynchronosus request
    # Message can be:
    # empty (equivalent of a GET)
    # string (the string will be wrapped into a JSON string automatically. Format: {"payload":"<message>"})
    # hash (the hash will be converted into a JSON string automatically)
    # json string (the JSON string will be sent as is)
    def Net.async_req (channel, message="", callback)
      # Pad channel
      new_channel = "#{Nutella.run_id}/#{channel}"
      # Prepare message
      m, id = prepare_message_for_request message
      # Initialize response
      # Prepare callback
      mqtt_cb = lambda do |message|
        m_id = extract_id_from_message message
        type, payload  = extract_nutella_fields_from_response message
        if m_id==id && type=='response'
          callback.call(payload)
          Nutella.mqtt.unsubscribe( new_channel, mqtt_cb )
        end
      end
      # Subscribe
      Nutella.mqtt.subscribe( new_channel, mqtt_cb )
      # Publish message
      Nutella.mqtt.publish( new_channel, m )
    end



    # Handle requests
    def Net.handle_requests( channel, callback)
      # Pad the channel
      new_channel = "#{Nutella.run_id}/#{channel}"
      mqtt_cb = lambda do |request|
        begin
          # Extract nutella fields
          type, payload, component_id, resource_id = extract_nutella_fields_from_message request
          id = extract_id_from_message request
          # Only handle requests that have proper id set
          return if type!='request' || id.nil?
          m = Net.prepare_message_for_response( callback.call( payload, component_id, resource_id ), id )
          Nutella.mqtt.publish( new_channel, m )
          # Assemble the response and check that it's proper JSON
        rescue
          return
        end
      end
      # Subscribe to the channel
      Nutella.mqtt.subscribe(new_channel, mqtt_cb)
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

    def Net.extract_nutella_fields_from_message(message)
      mh = JSON.parse(message)
      from = mh['from'].split('/')
      r_id = from.length==1 ? nil : from[1]
      return mh['type'], mh['payload'], from[0], r_id
    end

    def Net.extract_id_from_message( message )
      mh = JSON.parse(message)
      mh['id']
    end

    def Net.extract_nutella_fields_from_response( message )
      mh = JSON.parse(message)
      return mh['type'], mh['payload']
    end

    def Net.prepare_message_for_publish( message )
      from = Nutella.resource_id.nil? ? Nutella.component_id : "#{Nutella.component_id}/#{Nutella.resource_id}"
      if message.nil?
        return {type: 'publish', from: from}.to_json
      end
      {type: 'publish', from: from, payload: message}.to_json
    end

    def Net.prepare_message_for_response( message, id )
      from = Nutella.resource_id.nil? ? Nutella.component_id : "#{Nutella.component_id}/#{Nutella.resource_id}"
      if message.nil?
        return {id: id, type: 'response', from: from}.to_json
      end
      {id: id, type: 'response', from: from, payload: message}.to_json
    end

    def Net.prepare_message_for_request( message )
      from = Nutella.resource_id.nil? ? Nutella.component_id : "#{Nutella.component_id}/#{Nutella.resource_id}"
      if message.nil?
        return {id: message.hash, type: 'request', from: from}.to_json, message.hash
      end
      return {id: message.hash, type: 'request', from: from, payload: message}.to_json, message.hash
    end


  end
end