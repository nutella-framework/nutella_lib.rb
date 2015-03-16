require 'json'
require 'set'

require 'simple_mqtt_client/simple_mqtt_client'
require 'nutella_lib/core'
require 'nutella_lib/net'
require 'nutella_lib/persist'
require 'nutella_lib/app'
require 'nutella_lib/app_net'

# NO_EXT gets defined when you require "nutella_lib/noext", which
# signals that you don't want any extensions.
unless defined?(Nutella::NO_EXT)
  require 'nutella_lib/ext/kernel'
end
