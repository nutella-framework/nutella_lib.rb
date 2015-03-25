require 'json'

# Collection of items that are automatically persisted to a MongoDB collection
class JSONFilePersistedCollection

  # Creates a new JSONFilePersistedCollection
  #
  # @param [String] file the JSON file used to persist this collection
  def initialize( file )
    @filename = file
  end

end