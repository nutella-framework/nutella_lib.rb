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
            type, payload, component_id, resource_id = extract_nutella_fields_from_publish_message message
            callback.call(payload, channel, component_id, resource_id) if type=='publish'
          rescue
            return
          end
        end
      else
        mqtt_cb = lambda do |message|
          # Make sure the message is JSON, if not drop the message
          begin
            type, payload, component_id, resource_id = extract_nutella_fields_from_publish_message message
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
    def Net.sync_req (channel, message="")
      # Generate message unique id
      id = message.hash
      # Attach id
      begin
        payload = Net.attach_message_id(message, id)
      rescue
        STDERR.puts $!
        return
      end
      # Initialize response and response counter
      ready_to_go = 2
      response = nil
      # Subscribe to same channel to collect response
      Net.subscribe(channel, lambda do |res|
        if (res["id"]==id)
          ready_to_go -= 1
          if ready_to_go==0
            Net.unsubscribe(channel)
            response = res
          end
        end
      end)
      # Send message the message
      Net.publish(channel, payload)
      # Wait for the response to come back
      sleep(0.5) until ready_to_go==0
      response
    end


    # Performs an asynchronosus request
    # Message can be:
    # empty (equivalent of a GET)
    # string (the string will be wrapped into a JSON string automatically. Format: {"payload":"<message>"})
    # hash (the hash will be converted into a JSON string automatically)
    # json string (the JSON string will be sent as is)
    def Net.async_req (channel, message="", callback)
      # Generate message unique id
      id = message.hash
      # Attach id
      begin
        payload = Net.attach_message_id(message, id)
      rescue
        STDERR.puts $!
        return
      end
      # Initialize flag that prevents handling of our own messages
      ready_to_go = false
      # Register callback to handle data the request response whenever it comes
      Net.subscribe(channel, lambda do |res|
        # Check that the message we receive is not the one we are sending ourselves.
        if res["id"]==id
          if ready_to_go
            Net.unsubscribe(channel)
            callback.call(res)
          else
            ready_to_go = true
          end
        end
      end)
      # Send message
      Net.publish(channel, payload)
    end


    # Handles requests on a certain channel
    def Net.handle_requests (channel, &handler)
      Net.subscribe(channel, lambda do |req|
        # Ignore anything that doesn't have an id (i.e. not requests)
        id = req["id"]
        if id.nil?
          return
        end
        # Ignore recently processed requests
        if @last_requests.nil?
          @last_requests = Set.new
        end
        if @last_requests.include?(id)
          @last_requests.delete(id)
          return
        end
        @last_requests.add(id)
        req.delete("id")
        res = handler.call(req)
        begin
          res_and_id = attach_message_id(res, id)
          Net.publish(channel, res_and_id)
        rescue
          STDERR.puts 'When handling a request you need to return JSON'
        end
      end)
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

    def Net.extract_nutella_fields_from_publish_message(message)
      mh = JSON.parse(message)
      from = mh['from'].split('/')
      r_id = from.length==1 ? nil : from[1]
      return mh['type'], mh['payload'], from[0], r_id
    end


    def Net.prepare_message_for_publish( message )
      from = Nutella.resource_id.nil? ? Nutella.component_id : "#{Nutella.component_id}/#{Nutella.resource_id}"
      if message.nil?
        return {type: 'publish', from: from}.to_json
      end
      {type: 'publish', from: from, payload: message}.to_json
    end


    def Net.attach_message_id (message, id)
      if message.is_a?(Hash)
        message[:id] = id
        payload = message.to_json
      elsif message.is_json?
        p = JSON.parse(message)
        p[:id] = id
        payload = p.to_json
      elsif message.is_a?(String)
        payload = { :payload => message, :id => id }.to_json
      else
        raise 'Your request is not JSON!'
      end
      payload
    end


    def Net.prepare_message_for_request( message )

    end

  end
end