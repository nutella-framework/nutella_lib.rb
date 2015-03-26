require 'util/mongo_persisted_collection'
require 'util/json_file_persisted_collection'
require 'util/mongo_persisted_hash'
require 'util/json_file_persisted_hash'
require 'fileutils'


module Nutella

  module App

    # Implements basic app-dependent persistence for app-level components
    module Persist

      # This method returns a MongoDB-backed store (i.e. persistence)
      # for a collection (i.e. an Array)
      # @param [String] name the name of the store
      # @return [MongoPersistedCollection] a MongoDB-backed collection store
      def self.get_mongo_collection_store( name )
        MongoPersistedCollection.new Nutella.mongo_host, Nutella.app_id, name
      end

      # This method returns a MongoDB-backed store (i.e. persistence)
      # for a single object (i.e. an Hash)
      # @param [String] name the name of the store
      # @return [MongoPersistedHash] a MongoDB-backed Hash store
      def self.get_mongo_object_store( name )
        MongoPersistedHash.new Nutella.mongo_host, Nutella.app_id, 'app_persisted_hashes', name
      end

      # This method returns a JSON-file-backed store (i.e. persistence)
      # for a collection (i.e. an Array)
      # @param [String] name the name of the store
      # @return [JSONFilePersistedCollection] a JSON-file-backed collection store
      def self.get_json_collection_store( name )
        file_path = "data/#{name}.json"
        FileUtils.mkdir_p 'data/'
        JSONFilePersistedCollection.new file_path
      end

      # This method returns a JSON-file-backed store (i.e. persistence)
      # for a single object (i.e. an Hash)
      # @param [String] name the name of the store
      # @return [JSONFilePersistedHash] a JSON-file-backed Hash store
      def self.get_json_object_store( name )
        file_path = "data/#{name}.json"
        FileUtils.mkdir_p 'data/'
        JSONFilePersistedHash.new file_path
      end
    end
  end

end