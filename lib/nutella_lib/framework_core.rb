module Nutella
  #  Framework-level APIs sub-module
  module Framework

    # Initializes this component as a framework component
    # @param [String] broker_hostname
    # @param [String] component_id
    def self.init( broker_hostname, component_id )
      Nutella.app_id = nil
      Nutella.run_id = nil
      Nutella.component_id = component_id
      Nutella.resource_id = nil
      Nutella.mongo_host = broker_hostname
      Nutella.mqtt = SimpleMQTTClient.new broker_hostname

      # Start pinging
      Nutella.net.start_pinging
      # Fetch the `run_id`s list for this application and subscribe to its updates
      # net.async_request('app_runs_list', lambda { |res| Nutella.app.app_runs_list = res })
      # self.net.subscribe('app_runs_list', lambda {|message, _| Nutella.app.app_runs_list = message })
    end

    # Accessors for sub-modules
    def self.net; Nutella::Framework::Net; end
    def self.log; Nutella::Framework::Log; end
    def self.persist; Nutella::Framework::Persist; end

    # Parse command line arguments for framework-level components
    #
    # @param [Array] args command line arguments array
    # @return String broker address
    def self.parse_args(args)
      if args.length < 1
        STDERR.puts 'Couldn\'t read broker address from the command line, impossible to initialize component!'
        return
      end
      return args[0]
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
