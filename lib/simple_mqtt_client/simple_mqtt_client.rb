require 'mqtt'

# Simple asynchronous MQTT client
#  @author Alessandro Gnoli <tebemis@gmail.com>
class SimpleMQTTClient
  
  # Creates a new MQTT client
  #  @param [String] host the hostname of the MQTT broker we are connecting to
  #  @param [String] client_id the **unique** client identifier
  def initialize(host, client_id=nil)
    @host = host
    @channels = Hash.new
    @client = client_id.nil? ? MQTT::Client.connect(:host => host) : MQTT::Client.connect(host: host, client_id: client_id)
    @thread = Thread.new('mqtt') do
      @client.get do |channel, message|
        cbs = get_callbacks channel
        # If there is no callback (cb=nil) do nothing, otherwise call the right callback:
        # single channel callback with one parameter, wildcard channel callback with two.
        unless cbs.nil?
          (@channels.has_key? channel) ? cbs.each { |cb| cb.call(message) } : cbs.each { |cb| cb.call(message, channel) }
        end
      end
    end
  end

  # Subscribes to a channel and registers a callback
  # Single channel callbacks take only one parameter: the received message
  # Wildcard callbacks take two parameters: the received message and the channel the message was sent to
  #  @param [String] channel the channel or filter we are subscribing to
  #  @param [Proc] callback the callback that gets called
  #  whenever a messages is received
  def subscribe(channel, callback)
    if @channels.include?(channel)
      @channels[channel] << callback
    else
      @channels[channel]=[callback]
      @client.subscribe channel
    end
  end

  # Un-subscribes a specific callback from a channel
  #  @param [String] channel the channel we are un-subscribing from
  #  @param [Proc] callback the specific callback we want to remove
  def unsubscribe(channel, callback)
    if @channels.include? channel
      @channels[channel].delete(callback)
    end
    if @channels[channel].empty?
      @client.unsubscribe channel
      @channels.delete(channel)
    end
  end

  # Returns the a hash of all the channels this client is currently subscribed to
  # with relative callbacks
  #  @return [Hash] the hash of all the channels this client is currently subscribed to and relative callbacks
  def get_subscribed_channels
    @channels
  end

  # Returns true
  #  @return [Boolean] true if the channel is a wildcard channel. See MQTT specification for wildcard channels
  # {http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Toc398718106 here}
  # @param [String] channel the channel we are testing for wildcard
  def is_channel_wildcard?( channel )
    channel.include?('#') || channel.include?('+')
  end

  # Publishes a message to a channel
  #  @param [String] channel the channel we are publishing to
  #  @param [String] message the message we are publishing
  def publish(channel, message)
    @client.publish(channel, message)
  end

  # Disconnects this simple MQTT client instance from the broker
  def disconnect
    @client.disconnect
  end

  private

  # Gets the right callback associated to a channel
  # Specific callback gets precedence over wildcards
  def get_callbacks(channel)
    # First try to see if a callback for the exact channel exists
    return @channels[channel] if @channels.has_key? channel
    # If it doesn't then let's try to find a wildcard match
    pattern = wildcard_match channel
    return @channels[pattern] unless pattern.nil?
    # If there's no exact match or wildcard we have to return nil
    nil
  end

  # Returns the wildcard pattern, among the ones we subscribed to, that matches the channel.
  # This IGNORES exact matches!!!
  # It returns nil if the channel doesn't match any of the channels/filers we are subscribed to.
  def wildcard_match(channel)
    @channels.keys.each do |pattern|
      return pattern if matches_generic_pattern(channel, pattern)
    end
    # If we go through the whole list of channels and there is no generic pattern then return nil
    nil
  end

  # Returns true if the string matches a pattern (including the exact pattern)
  def matches_generic_pattern(str, pattern)
    # If multi-level wildcard is the only character in pattern, then any string will match
    return true if pattern=='#'
    # Handle all other multi-level wildcards
    p_wo_wildcard = pattern[0..-2]
    str_wo_details = str[0..pattern.length-2]
    return true if pattern[-1, 1]=='#' && p_wo_wildcard==str_wo_details
    # TODO Handle single-level wildcards (+)
    false
  end
  
end
