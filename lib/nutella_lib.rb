require 'json'
require 'set'

require 'simple_mqtt_client/simple_mqtt_client'

require 'nutella_lib/core'
require 'nutella_lib/net'
require 'nutella_lib/log'
require 'nutella_lib/persist'

require 'nutella_lib/app_core'
require 'nutella_lib/app_net'
require 'nutella_lib/app_log'
require 'nutella_lib/app_persist'

require 'nutella_lib/framework_core'
require 'nutella_lib/framework_net'
require 'nutella_lib/framework_log'
require 'nutella_lib/framework_persist'

# NO_EXT gets defined when you require "nutella_lib/noext", which
# signals that you don't want any extensions.
unless defined?(Nutella::NO_EXT)
  require 'nutella_lib/ext/kernel'
end

# Make sure any exception in any thread kills the program
Thread::abort_on_exception = true
