module Nutella

  # This class implements the pub/sub nutella protocol
  # @author Alessandro Gnoli <tebemis@gmail.com>
  module Net

    # Subscribe to a channel
    # The callback takes one parameter and that is the message that is received.
    # Messages that are not JSON are discarded.
    def Net.subscribe (channel, callback)
      # Pad the channel
      new_channel = Nutella.run_id + '/' + channel
      # Subscribe
      # Depending on what type of channel we are subscribing to (wildcard or simple)
      # register a different kind of callback
      if Nutella.mqtt.is_channel_wildcard?(channel)
        Nutella.mqtt.subscribe(
            new_channel,
            lambda do |message, channel|
              # Make sure the message is JSON, if not drop the message
              begin
                message_hash = JSON.parse(message)
                callback.call(message_hash, channel)
              rescue
                return
              end
            end
        )
      else
        Nutella.mqtt.subscribe(
            new_channel,
            lambda do |message|
              # Make sure the message is JSON, if not drop the message
              begin
                message_hash = JSON.parse(message)
                callback.call(message_hash)
              rescue
                return
              end
            end
        )
      end
    end

    # Unsubscribe from a channel
    def Net.unsubscribe(channel)
      # Pad the channel
      new_channel = Nutella.run_id + '/' + channel
      # Unsubscribe
      Nutella.mqtt.unsubscribe(new_channel)
    end

    # Publishes a message to a channel
    # Message can be:
    # empty (equivalent of a GET)
    # string (the string will be wrapped into a JSON string automatically. Format: {"payload":"<message>"})
    # hash (the hash will be converted into a JSON string automatically)
    # json string (the JSON string will be sent as is)
    def Net.publish(channel, message)
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


    def Net.listen
      begin
        sleep
      rescue Interrupt
        # Simply returns
      end
    end


    private

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

    def Net.prepare_message_for_publish (message)
      if message.is_a?(Hash)
        message[:from] = Nutella.actor_name
        payload = message.to_json
      elsif message.is_json?
        p = JSON.parse(message)
        p[:from] = Nutella.actor_name
        payload = p.to_json
      elsif message.is_a?(String)
        payload = { :payload => message, :from => Nutella.actor_name }.to_json
      else
        raise 'You are trying to publish something that is not JSON!'
      end
      payload
    end

  end
end