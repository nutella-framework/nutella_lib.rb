require 'nutella_lib/core'
require 'nutella_lib/net'

# Gems used across the whole library
require 'simple_ruby_mqtt_client'
require 'json'
require 'set'

# NO_EXT gets defined when you require "nutella_lib/noext", which
# signals that you don't want any extensions.
unless defined?(Nutella::NO_EXT)
  require 'nutella_lib/ext/kernel'
end