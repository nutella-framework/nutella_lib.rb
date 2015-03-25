require 'util/json_store'

# An hash that is automatically persisted to a JSON file.
# This class behaves *similarly* to a regular Hash but it persists every operation
# to a specified JSON file.
# Not all Hash operations are supported and we added some of our own.
class JSONFilePersistedHash

  def initialize( file )
    @store = JSONStore.new(file, true)
  end


  # Methods borrowed from Ruby's Hash class

  def []( key )
    @store.transaction { @store[key] }
  end

  def []=( key, val )
    @store.transaction { @store[key]=val }
  end

  def delete( key )
    @store.transaction { @store.delete key }
  end

  def empty?
    @store.transaction { @store.to_h.empty? }
  end

  def has_key?( key )
    @store.transaction { @store.to_h.has_key? key }
  end

  def include?( key )
    has_key? key
  end

  def to_s
    @store.transaction { @store.to_h.to_s }
  end

  def to_h
    @store.transaction { @store.to_h }
  end

  def keys
    @store.transaction { @store.to_h.keys }
  end

  def length
    @store.transaction { @store.to_h.length }
  end


  # PersistedHash-only public methods

  # Adds a <key, value> pair to the PersistedHash _only if_
  # there is currently no value associated with the specified key.
  # @return [Boolean] false if the key already exists, true if the
  # <key, value> pair was added successfully
  def add_key_value?(key, val)
    @store.transaction do
      return false if @store.to_h.key? key
      @store[key]=val
    end
    true
  end

  # Removes a <key, value> pair from the PersistedHash _only if_
  # there is currently a value associated with the specified key.
  # @return [Boolean] false if there is no value associated with
  # the specified key, true otherwise
  def delete_key_value?( key )
    @store.transaction { return false if @store.delete(key).nil? }
    true
  end

end