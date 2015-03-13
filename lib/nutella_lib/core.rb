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


  # Initializes this component as an application component
  # @param [String] broker_hostname
  # @param [String] component_id
  def self.init_as_app_component( broker_hostname, app_id, component_id )
    @app_id = app_id
    @run_id = nil
    @component_id = component_id
    @resource_id = nil
    @mqtt = SimpleMQTTClient.new broker_hostname
    # Fetch the `run_id`s list for this application and subscribe to its updates
    @app_runs_list = net.app.sync_request('app_runs_list')
    net.app.subscribe('app_runs_list', lambda {|message, _| @app_runs_list = message })
  end


  # Accessors for app_id
  def self.app_id; @app_id end

  # Accessors for run_id
  def self.run_id; @run_id end

  # Accessors for mqtt client
  def self.mqtt;
    raise 'Nutella has not been initialized: you need to call the proper init method before you can start using nutella' if @mqtt.nil?
    @mqtt
  end

  # Accessors for component_id
  def self.component_id;
    raise 'Nutella has not been initialized: you need to call the proper init method before you can start using nutella' if @component_id.nil?
    @component_id
  end

  # Accessors for resource_id
  def self.resource_id; @resource_id end

  # Accessor for runs list
  def self.app_runs_list; @app_runs_list end

  # Accessor for the net module
  def self.net; Nutella::Net end

  # Accessor for the persist module
  def self.persist; Nutella::Persist end


  # Utility functions


  # Parse command line arguments for run level components
  #
  # @param [Array] args command line arguments array
  # @return [String, String, String] broker, app_id and run_id
  def self.parse_run_component_args(args)
    if args.length < 3
      STDERR.puts 'Couldn\'t read broker address, app_id and run_id from the command line, impossible to initialize component!'
      return
    end
    return args[0], args[1], args[2]
  end


  # Parse command line arguments for app level components
  #
  # @param [Array] args command line arguments array
  # @return [String, String] broker and app_id
  def self.parse_app_component_args(args)
    if args.length < 2
      STDERR.puts 'Couldn\'t read broker address and app_id from the command line, impossible to initialize component!'
      return
    end
    return args[0], args[1]
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




