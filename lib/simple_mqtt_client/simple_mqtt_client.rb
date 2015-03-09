require 'mqtt'

# Simple MQTT client
#  @author Alessandro Gnoli <tebemis@gmail.com>
class SimpleMQTTClient

  ## Private instance variables
  # @channels is a hash that associates to each channels a set of callbacks
  # @client low-level mqtt client
  # @thread the packet reader thread


  # Creates a new MQTT client
  #  @param [String] host the hostname of the MQTT broker we are connecting to
  #  @param [String] client_id the **unique** client identifier
  def initialize( host, client_id=nil )
    @channels = Hash.new
    @client = client_id.nil? ? MQTT::Client.connect(:host => host) : MQTT::Client.connect(host: host, client_id: client_id)
    @thread = Thread.new('mqtt') do
      @client.get do |channel, message|
        # Execute all the appropriate callbacks:
        # the ones specific to this channel with a single parameter (message)
        # the ones associated to a wildcard channel, with two parameters (message and channel)
        cbs = get_callbacks channel
        cbs.each { |cb| (@channels.has_key? channel) ? cb.call(message) : cb.call(message, channel) }
      end
    end
  end

  # Subscribes to a channel and registers a callback
  # Single channel callbacks take only one parameter: the received message.
  # Wildcard callbacks take two parameters: the received message and the channel the message was sent to.
  # It is possible to register multiple callbacks per channel. All of them will be executed whenever a message
  # on that channel is received.
  # Note that overlaps between channel-specific callbacks and wildcard-filters are allowed.
  #  @param [String] channel the channel or filter we are subscribing to
  #  @param [Proc] callback the callback that gets called
  #  whenever a messages is received
  def subscribe( channel, callback )
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
  def unsubscribe( channel, callback )
    if @channels.include? channel
      @channels[channel].delete(callback)
    end
    if @channels[channel].empty?
      @client.unsubscribe channel
      @channels.delete(channel)
    end
  end

  # Publishes a message to a channel
  #  @param [String] channel the channel we are publishing to
  #  @param [String] message the message we are publishing
  def publish( channel, message )
    @client.publish(channel, message)
  end

  # Disconnects this simple MQTT client instance from the broker
  def disconnect
    @thread.exit
    @client.disconnect
    @channels.clear
  end

  # Returns a hash of all the channels this client is currently subscribed to with relative callbacks
  #  @return [Hash] all channels this client is currently subscribed to, and relative callbacks
  def get_subscribed_channels
    @channels
  end

  # Returns true if a channel is a wildcard channel
  #  @return [Boolean] true if the channel is a wildcard channel. See MQTT specification for wildcard channels
  # {http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Toc398718106 here}
  # @param [String] channel the channel we are testing for wildcard
  def is_channel_wildcard?( channel )
    channel.include?('#') || channel.include?('+')
  end

  private

  # Gets all the callbacks associated to a channel
  def get_callbacks( channel )
    cbs = Array.new
    # First, fetch all the channel-specific callbacks...
    cbs.concat @channels[channel] if @channels.has_key? channel
    # ...then fetch the callbacks matching all wildcard-filters
    cbs.concat wildcard_callbacks channel
    cbs
  end

  # Gets all wildcard callbacks associated to a channel
  # Among the filters we are subscribed to, which ones match the channel?
  def wildcard_callbacks( channel )
    # First select all filters
    filters = @channels.keys.select { |ch| is_channel_wildcard? ch}
    # Then select filters that match channel
    matching_filters = filters.select { |filter| matches_wildcard_pattern(channel, filter) }
    # Add all callbacks that are associated to matching filters
    cbs = Array.new
    matching_filters.each { |ch| cbs.concat @channels[ch] }
    cbs
  end

  # Returns true if the string matches a pattern
  # See http://docs.oasis-open.org/mqtt/mqtt/v3.1.1/os/mqtt-v3.1.1-os.html#_Toc398718107
  # for a formal description of the rules
  def matches_wildcard_pattern(str, pattern)
    # First we need to build a regex out of the pattern
    regex = build_regex_from_pattern pattern
    # Then we check if the regex matches the string
    !!(regex =~ str)
  end

  # Escape '/'
  # Substitute '+' for '[^"\/"]+' (a string of one or more characters that is are not '/')
  # Substitute '/#' with '.*' (a string of zero or more characters)
  # Substitute '#' for '.*' (a string of zero or more characters)
  def build_regex_from_pattern( pattern )
    regex_str = pattern.gsub('/','\\/').gsub('+','[^"\/"]+').gsub('\/#','.*').gsub('#','.*')
    Regexp.new regex_str
  end
  
end
