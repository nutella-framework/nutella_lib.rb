require 'nutella_lib/core'
require 'nutella_lib/net'
require 'nutella_lib/net_app'
require 'nutella_lib/persist'
require 'simple_mqtt_client/simple_mqtt_client'

# Gems used across the whole library
require 'json'
require 'set'

# NO_EXT gets defined when you require "nutella_lib/noext", which
# signals that you don't want any extensions.
unless defined?(Nutella::NO_EXT)
  require 'nutella_lib/ext/kernel'
end
