module Nutella

  module App

    # Initializes this component as an application component
    # @param [String] broker_hostname
    # @param [String] component_id
    def self.init( broker_hostname, app_id, component_id )
      Nutella.app_id = app_id
      Nutella.run_id = nil
      Nutella.component_id = component_id
      Nutella.resource_id = nil
      Nutella.mqtt = SimpleMQTTClient.new broker_hostname
      # Fetch the `run_id`s list for this application and subscribe to its updates
      @app_runs_list = net.sync_request('app_runs_list')
      self.net.subscribe('app_runs_list', lambda {|message, _| Nutella.app.app_runs_list = message })
    end

    # Setter/getter for runs_list
    def self.app_runs_list=(val) @app_runs_list=val; end
    def self.app_runs_list; @app_runs_list end

    # Accessors for sub-modules
    def self.net; Nutella::App::Net; end
    def self.log; Nutella::App::Log; end


    # Parse command line arguments for app level components
    #
    # @param [Array] args command line arguments array
    # @return [String, String] broker and app_id
    def self.parse_args(args)
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
      Nutella.extract_component_id
    end

    # Sets the resource id
    #
    # @param [String] resource_id the resource id (i.e. the particular instance of this component)
    def self.set_resource_id( resource_id )
      Nutella.set_resource_id resource_id
    end


  end

end