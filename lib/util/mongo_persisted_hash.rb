require 'mongo'

# An hash that is automatically persisted to a MongoDB document.
# This class behaves *similarly* to a regular Hash but it persists every operation
# to a specified MongoDB document.
# Not all Hash operations are supported and we added some of our own.
class MongoPersistedHash

  # Creates a new MongoPersistedHash that is persisted as a document
  # with _id +name+ inside a MongoDB collection
  #
  # @param [String] hostname of the MongoDB server
  # @param [String] db the database where we want to persist the array
  # @param [String] collection the collection we are using to persist this collection
  # @param [String] name the _id of the document we are using to persist this Hash
  def initialize(  hostname, db, collection, name )
    Mongo::Logger.logger.level = ::Logger::INFO
    client = Mongo::Client.new([hostname], :database => db)
    @collection = client[collection]
    @doc_id = name

    # Semaphore for the write on DB synchronization
    @s = Mutex.new

    # Enable / disable auto save
    @auto_save = true;

  end

  # Enable/disable auto save
  def set_auto_save(as)
    @auto_save = as
  end


  # Methods borrowed from Ruby's Hash class

  def []( key )
    hash = load_hash
    hash[key]
  end

  def []=( key, val )
    hash = load_hash
    hash[key]=val
    store_hash hash
  end

  def delete( key )
    hash = load_hash
    return_value = hash.delete key
    store_hash hash
    return_value
  end

  def empty?
    hash = load_hash
    hash.delete '_id'
    hash.empty?
  end

  def has_key?( key )
    hash = load_hash
    hash.has_key? key
  end

  def include?( key )
    has_key? key
  end

  def to_s
    hash = load_hash
    hash.delete '_id'
    hash.to_s
  end

  def to_h
    hash = load_hash
    hash.delete '_id'
    hash
  end

  def keys
    hash = load_hash
    hash.delete '_id'
    hash.keys
  end

  def length
    hash = load_hash
    hash.delete '_id'
    hash.length
  end


  # PersistedHash-only public methods

  # Adds a <key, value> pair to the PersistedHash _only if_
  # there is currently no value associated with the specified key.
  # @return [Boolean] false if the key already exists, true if the
  # <key, value> pair was added successfully
  def add_key_value?(key, val)
    hash = load_hash
    return false if hash.key? key
    hash[key] = val
    store_hash hash
    true
  end

  # Removes a <key, value> pair from the PersistedHash _only if_
  # there is currently a value associated with the specified key.
  # @return [Boolean] false if there is no value associated with
  # the specified key, true otherwise
  def delete_key_value?( key )
    hash = load_hash
    return false if hash.delete(key).nil?
    store_hash hash
    true
  end


  # private

  def load_hash
    if(!defined? @r)
      @s.synchronize {
        @r = @collection.find({_id: @doc_id}).limit(1).first
      }
    end
    @r.nil? ? {'_id' => @doc_id} : @r
  end


  def store_hash(hash)
    @s.synchronize {
      @r = hash
      if(@auto_save and !@r.empty?)
        @collection.find({'_id' => @doc_id}).find_one_and_replace(@r, :upsert => :true)
      end
    }
  end

  def save
    @s.synchronize {
      if(defined? @r and !@r.empty?)
        @collection.find({'_id' => @doc_id}).find_one_and_replace(@r, :upsert => :true)
      end
    }
  end




end
