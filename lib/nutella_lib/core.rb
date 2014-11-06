# This module is the wrapper around the whole nutella library.
module Nutella


  # Adding a convenience method to the string class to test if it contains properly formatted JSON
  class String
    def is_json?
      begin
        !!JSON.parse(self)
      rescue
        false
      end
    end
  end


  # Initializes the nutella library
  def Nutella.init(args)
    if args.length < 2
      STDERR.puts "Couldn't read run_id and broker address from the command line, impossible to initialize library!"
      return
    end
    @run_id = args[0]
    begin
      @actor_name = Nutella.config_actor_name(@run_id)
    rescue
      STDERR.puts "Couldn't find nutella.json file, impossible to initialize library!"
      return
    end
      @mqtt = SimpleMQTTClient.new(args[1], @actor_name)
  end


  # Accessors for module instance variables
  def Nutella.run_id; @run_id end
  def Nutella.actor_name; @actor_name end
  def Nutella.mqtt; @mqtt end


  # Nutella library modules loading
  def Nutella.net; Nutella::Net end


  private

  # Extracts the actor name from nutella.json file and appends it to the run_id
  def Nutella.config_actor_name (run_id)
    h = JSON.parse( IO.read( "nutella.json" ) )
    full_actor_name = run_id + '_' + h["name"]
    full_actor_name[0, 23]
  end

end




