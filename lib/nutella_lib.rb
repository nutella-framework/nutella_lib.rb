require 'nutella_lib/core'
#require 'nutella_lib/space/space'
# Here is where we'll require the protocol extensions

# NO_EXT gets defined when you require "nutella_lib/noext", which
# signals that you don't want any extensions.
unless defined?(Nutella::NO_EXT)
  require 'nutella_lib/ext/kernel'
end