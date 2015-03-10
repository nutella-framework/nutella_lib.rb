module Nutella
  module Net

    # This module implements the pub/sub and request/response APIs at the application level
    module App

      # Store the subscriptions and the relative callbacks
      @subscriptions = []
      @callbacks = []


      # @!group Application-level communication APIs


      # Subscribes to a channel or to a set of channels at the application-level.
      #
      # @param [String] channel the application-level channel or filter we are subscribing to. Can contain wildcard(s)
      # @param [Proc] callback a lambda expression that is fired whenever a message is received.
      #   The passed callback takes the following parameters:
      #   - [String] message: the received message. Messages that are not JSON are discarded.
      #   - [String] channel: the application-level channel the message was received on (optional, only for wildcard subscriptions)
      #   - [Hash] from: the sender's identifiers (run_id, app_id, component_id and optionally resource_id)
      def App.subscribe (channel, callback)
        Nutella::Net.subscribe_to( channel, callback, :pad_to_app_ch, :un_pad_app_ch )
      end


      # Un-subscribes from an application-level channel
      #
      # @param [String] channel the application level channel we want to unsubscribe from. Can contain wildcard(s).
      def App.unsubscribe( channel )
        Nutella::Net.unsubscribe_to( channel, :pad_to_app_ch)
      end


      # Publishes a message to an application-level channel
      #
      # @param [String] channel the application-level channel we want to publish the message to. *CANNOT* contain wildcard(s)!
      # @param [Object] message the message we are publishing. This can be,
      #   nil/empty (default), a string, a hash and, in general, anything with a .to_json method.
      def App.publish(channel, message=nil)
        Nutella::Net.publish_to(channel, message, :pad_to_app_ch)
      end


      # Performs a synchronous request at the application-level
      #
      # @param [String] channel the application-level channel we want to make the request to. *CANNOT* contain wildcard(s)!
      # @param [Object] message the body of request. This can be,
      #   nil/empty (default), a string, a hash and, in general, anything with a .to_json method.
      def App.sync_request ( channel, message=nil )
        Nutella::Net.sync_request_to(channel, message, :pad_to_app_ch)
      end


      # Performs an asynchronous request at the application-level
      #
      # @param [String] channel the application-level channel we want to make the request to. *CANNOT* contain wildcard(s)!
      # @param [Object] message the body of request. This can be,
      #   nil/empty (default), a string, a hash and, in general, anything with a .to_json method.
      def App.async_request ( channel, message=nil, callback )
        Nutella::Net.async_request_to(channel, message, callback, :pad_to_app_ch)
      end


      # Handles requests on a certain application-level channel
      #
      # @param [String] channel tha application-level channel we want to listen for requests on. Can contain wildcard(s).
      # @param [Proc] callback a lambda expression that is fired whenever a message is received.
      #   The passed callback takes the following parameters:
      #   - [String] the received message (payload). Messages that are not JSON are discarded.
      #   - [Hash] the sender's identifiers (run_id, app_id, component_id and optionally resource_id)
      #   - [*returns* Hash] The response sent back to the client that performed the request. Whatever is returned by the callback is marshaled into a JSON string and sent via MQTT.
      def App.handle_requests( channel, callback )
        Nutella::Net.handle_requests_to(channel, callback, :pad_to_app_ch)
      end


      # @!endgroup


      # @!group Application-level APIs to communicate at the run-level


      def publish_to_run( run_id, channel, message )
      #   Publishes message to the run level channel /nutella/apps/app_id/runs/run_id/channel.
      end

      def subscribe_to_run( run_id, channel, callback )
        # Subscribes to the run level channel /nutella/apps/app_id/runs/run_id/channel. The from parameter in the callback is a hash (i.e. object in JavaScript, Hash in Ruby, HashMap in Java,...) containing the type of component that sent the message and the fields of the from that are set (see above).
        # cb
      end

      def unsubscribe_to_run( run_id, channel, callback )
        # Subscribes to the run level channel /nutella/apps/app_id/runs/run_id/channel. The from parameter in the callback is a hash (i.e. object in JavaScript, Hash in Ruby, HashMap in Java,...) containing the type of component that sent the message and the fields of the from that are set (see above).
        # cb
      end

      def sync_request_to_run( run_id, channel, request)
         # Makes a request to the run level channel /nutella/apps/app_id/runs/run_id/channel
      end

      def async_request_to_run( run_id, channel, request, callback)
        # Makes a request to the run level channel /nutella/apps/app_id/runs/run_id/channel
        #   cb (resposnse)
      end

      def handle_requests_on_run(run_id, channel, callback )
        # Handles requests on the run level channel /nutella/apps/app_id/runs/run_id/channel.
    #     (request, from)
      end


      # @!endgroup


      # @!group Application level APIs to communicate at the run-level (broadcast)


      def publish_to_all_runs( channel, message )
        # Publishes message to the same run level channel (/nutella/apps/app_id/runs/+/channel) for all run_ids.
      end

      def subscribe_to_all_runs( channel, callback )
        # Subscribes to the same run level channel (/nutella/apps/app_id/runs/+/channel) for all run_ids. The from parameter in the callback is a hash (i.e. object in JavaScript, Hash in Ruby, HashMap in Java,...) containing the type of component that sent the message and the fields of the from that are set (see above).
        # cb (message, from)
      end

      def request_to_all_runs(channel, request, callback)
        # Makes a request to the same run level channel (/nutella/apps/app_id/runs/+/channel) for all run_ids.
        # cb(response)
      end

      def handle_requests_on_all_runs(channel, callback)
        # Handles requests to the same run level channel (/nutella/apps/app_id/runs/+/channel) for all run_ids.
        # callback(request, from)
      end


      # @!endgroup

      private

      def Net.pad_to_app_ch( channel )
        "/nutella/apps/#{Nutella.app_id}/#{channel}"
      end

      def Net.un_pad_app_ch( channel )
        channel.gsub("/nutella/apps/#{Nutella.app_id}/", '')
      end


    end

  end
end
