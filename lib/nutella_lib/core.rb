# This module is the wrapper around the whole nutella library.
module Nutella


  # Initializes this component as a run component
  # @param [String] run_id
  # @param [String] broker_hostname
  # @param [String] component_id
  def self.init( broker_hostname, app_id, run_id, component_id )
    @app_id = app_id
    @run_id = run_id
    @component_id = component_id
    @resource_id = nil
    @mqtt = SimpleMQTTClient.new broker_hostname
  end


  # Variables accessors
  def self.app_runs_list; @app_runs_list end
  def self.app_id; @app_id end
  def self.run_id; @run_id end
  def self.resource_id; @resource_id end
  def self.component_id;
    raise 'Nutella has not been initialized: you need to call the proper init method before you can start using nutella' if @component_id.nil?
    @component_id
  end
  def self.mqtt;
    raise 'Nutella has not been initialized: you need to call the proper init method before you can start using nutella' if @mqtt.nil?
    @mqtt
  end

  # Variables Setters
  def self.app_runs_list=(val) @app_runs_list=val; end
  def self.app_id=(val); @app_id=val; end
  def self.run_id=(val); @run_id=val; end
  def self.resource_id=(val); @resource_id=val; end
  def self.component_id=(val); @component_id=val; end
  def self.mqtt=(val); @mqtt=val; end


  # Accessors for sub-modules
  def self.app; Nutella::App end
  def self.net; Nutella::Net end
  def self.persist; Nutella::Persist end


  # Utility functions


  # Parse command line arguments for run level components
  #
  # @param [Array] args command line arguments array
  # @return [String, String, String] broker, app_id and run_id
  def self.parse_args(args)
    if args.length < 3
      STDERR.puts 'Couldn\'t read broker address, app_id and run_id from the command line, impossible to initialize component!'
      return
    end
    return args[0], args[1], args[2]
  end


  # Extracts the component name from the folder where the code for this component is located
  #
  # @return [String] the component name
  def self.extract_component_id
    path = Dir.pwd
    path[path.rindex('/')+1..path.length-1]
  end


  # Sets the resource id
  #
  # @param [String] resource_id the resource id (i.e. the particular instance of this component)
  def self.set_resource_id( resource_id )
    @resource_id = resource_id
  end

end




