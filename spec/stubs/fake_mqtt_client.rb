module MQTT  
  # This class is a "stub: MQTT client that can be used to simplify
  # testing drastically.
  # It has methods that allow to "write" topics in order to send fake
  # messages it is a double fo
  class FakeMQTTClient

    def self.connect(*args)
      return FakeMQTTClient.new
    end

    def subscribe(*topics)
    end

    def unsubscribe(*topics)
    end

    def get
    end

    def publish(topic, payload = '')
      puts "Hey! Someone published on #{topic}: #{payload}"
    end

    def disconnect
    end

  end
end