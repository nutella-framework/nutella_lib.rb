# This module is the wrapper around the whole nutella library.
module Nutella

  # Initializes the nutella library
  def Nutella.init(args)
    if args.length < 2
      STDERR.puts "Couldn't read run_id and broker address from the command line, impossible to initialize library!"
      return
    end
    @run_id = args[0]
    @actor_name = Nutella.config_actor_name
    @mqtt = SimpleMQTTClient.new(args[1])
  end


  # Accessors for module instance variables
  def Nutella.run_id; @run_id end
  def Nutella.actor_name; @actor_name end
  def Nutella.mqtt; @mqtt end


  # Nutella library modules loading
  def Nutella.net; Nutella::Net end
  def Nutella.persist; Nutella::Persist end


  private

  # Extracts the actor name based on the the folder where we are executing
  def Nutella.config_actor_name
    path = Dir.pwd
    path[path.rindex('/')+1..path.length-1]
  end

end




