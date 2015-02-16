# This module is the wrapper around the whole nutella library.
module Nutella


  # Initializes the nutella library
  # @param [String] run_id
  # @param [String] broker_hostname
  # @param [String] component_id
  def self.init(run_id, broker_hostname, component_id)
    @run_id = run_id
    @component_id = component_id
    @resource_id = nil
    @mqtt = SimpleMQTTClient.new broker_hostname
  end


  # Accessors for module instance variables
  def self.run_id; @run_id end
  def self.component_id; @component_id end
  def self.resource_id; @resource_id end
  def self.mqtt; @mqtt end



  # Nutella library modules loading
  def self.net; Nutella::Net end
  def self.persist; Nutella::Persist end


  # Utility functions


  # Parse command line arguments
  def self.parse_args(args)
    if args.length < 2
      STDERR.puts "Couldn't read run_id and broker address from the command line, impossible to initialize library!"
      return
    end
    return args[0], args[1]
  end


  # Extracts the actor name based on the the folder where we are executing
  def self.extract_component_id
    path = Dir.pwd
    path[path.rindex('/')+1..path.length-1]
  end


  # Sets the resource id
  def self.set_resource_id( resource_id )
    @resource_id = resource_id
  end

end




