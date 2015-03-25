require 'mongo'

# Collection of items that are automatically persisted to a MongoDB collection
class MongoPersistedCollection


  # Creates a new MongoPersistedCollection
  #
  # @param [String] hostname of the MongoDB server
  # @param [String] db the database where we want to persist the array
  # @param [String] collection the collection we are using to persist this collection
  def initialize( hostname, db, collection )
    Mongo::Logger.logger.level = ::Logger::INFO
    client = Mongo::Client.new([hostname], :database => db)
    @collection = client[collection]
  end


  # Pushes (appends) the given hash on to the end of this persisted collection
  #
  # @param [Hash] item the object we want to append
  # @return [MongoPersistedCollection] the persisted collection itself, so several appends may be chained together
  def push( item )
    @collection.insert_one item
    self
  end


  # Deletes the first element from this persisted collection that is equal to item
  #
  # @param [Hash] item the object we want to delete
  # @return [Hash] the object we just deleted
  def delete( item )
    from_bson_to_hash @collection.find(item).find_one_and_delete
  end


  # Replaces the first element from this persisted array that matches item, with replacement
  #
  # @param [Hash] replacement for the current element
  # @return [Hahs] the item that was replaced, {} if the element wasn't in the collection
  def replace( item, replacement )
    r = delete item
    push replacement
    r
  end


  # Returns an array representation of this collection
  #
  # @return [Array<Hash>] array representation of this persisted collection
  def to_a
    ta = Array.new
    @collection.find.each do |doc|
      ta.push from_bson_to_hash(doc)
    end
    ta
  end

  # Returns the length of the collection
  #
  # @return [Fixnum] the length of the collection
  def length
    @collection.find.count.to_i
  end

  private


  def from_bson_to_hash( item )
    h = item.to_h
    h.delete '_id'
    h
  end

end