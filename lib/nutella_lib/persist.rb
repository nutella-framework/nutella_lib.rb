require 'util/mongo_persisted_collection'
require 'util/json_file_persisted_collection'
require 'util/mongo_persisted_hash'
require 'util/json_file_persisted_hash'
require 'fileutils'


module Nutella

  # Implements basic run-dependent persistence for run-level components
  module Persist

    # This method returns a MongoDB-backed store (i.e. persistence)
    # for a collection (i.e. an Array)
    # @param [String] name the name of the store
    # @return [MongoPersistedCollection] a MongoDB-backed collection store
    def self.get_mongo_collection_store( name )
      collection = "#{Nutella.run_id}/#{name}"
      MongoPersistedCollection.new Nutella.mongo_host, Nutella.app_id, collection
    end

    # This method returns a MongoDB-backed store (i.e. persistence)
    # for a single object (i.e. an Hash)
    # @param [String] name the name of the store
    # @return [MongoPersistedHash] a MongoDB-backed Hash store
    def self.get_mongo_object_store( name )
      doc_id = "#{Nutella.run_id}/#{name}"
      MongoPersistedHash.new Nutella.mongo_host, Nutella.app_id, 'run_persisted_hashes', doc_id
    end

    # This method returns a JSON-file-backed store (i.e. persistence)
    # for a collection (i.e. an Array)
    # @param [String] name the name of the store
    # @return [JSONFilePersistedCollection] a JSON-file-backed collection store
    def self.get_json_collection_store( name )
      dir_path = "data/#{Nutella.run_id}"
      file_path = "data/#{Nutella.run_id}/#{name}.json"
      FileUtils.mkdir_p dir_path
      JSONFilePersistedCollection.new file_path
    end

    # This method returns a JSON-file-backed store (i.e. persistence)
    # for a single object (i.e. an Hash)
    # @param [String] name the name of the store
    # @return [JSONFilePersistedHash] a JSON-file-backed Hash store
    def self.get_json_object_store( name )
      dir_path = "data/#{Nutella.run_id}"
      file_path = "data/#{Nutella.run_id}/#{name}.json"
      FileUtils.mkdir_p dir_path
      JSONFilePersistedHash.new file_path
    end


  end

end