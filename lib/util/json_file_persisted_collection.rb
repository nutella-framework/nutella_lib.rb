require 'json'
require 'util/json_store'

# Collection of items that are automatically persisted to a JSON file
class JSONFilePersistedCollection

  # Creates a new JSONFilePersistedCollection
  #
  # @param [String] file the JSON file used to persist this collection
  def initialize( file )
    @store = JSONStore.new(file, true)
  end


  # Pushes (appends) the given hash on to the end of this persisted collection
  #
  # @param [Hash] item the object we want to append
  # @return [JSONFilePersistedCollection] the persisted collection itself, so several appends may be chained together
  def push( item )
    @store.transaction do
      @store['collection'] = Array.new if @store['collection'].nil?
      @store['collection'].push(item)
    end
    self
  end


  # Deletes the first element from this persisted collection that is equal to item
  #
  # @param [Hash] item the object we want to delete
  # @return [Hash] the object we just deleted
  def delete( item )
    r = nil
    @store.transaction do
      if @store['collection'].nil?
        r = {}
        @store.abort
      end
      r = @store['collection'].delete_at(@store['collection'].index(item) || @store['collection'].length)
      r = {} if r.nil?
    end
    r
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
    @store.transaction { @store['collection'].nil? ? {} : @store['collection'] }
  end

  # Returns the length of the collection
  #
  # @return [Fixnum] the length of the collection
  def length
    @store.transaction { @store['collection'].nil? ? 0 : @store['collection'].length }
  end

end