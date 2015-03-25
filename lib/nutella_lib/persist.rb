require 'util/mongo_persisted_collection'
require 'util/mongo_persisted_hash'
require 'util/json_file_persisted_collection'
require 'util/json_file_persisted_hash'
# require 'lib/util/json_store'


module Nutella

  # Implements basic run-dependent persistence for run-level components
  module Persist

    # This method returns a JSONStore (file based persitence)
    # def self.get_json_store(file_name)
    #   dir = file_name[0..file_name.rindex('/')]
    #   file = file_name[file_name.rindex('/')..file_name.length-1]
    #   new_dir = dir + Nutella.run_id
    #   FileUtils.mkdir_p new_dir
    #   JSONStore.new(new_dir + file, true)
    # end


    # This method returns a MongoDB-backed store (i.e. persistence)
    # for a collection (i.e. an Array)
    # @param [String] name the name of the store
    # @return [MongoPersistedCollection] a MongoDB backed Array/collection store
    def self.get_mongo_collection_store( name )

    end

    # This method returns a MongoDB-backed store (i.e. persistence)
    # for a single object (i.e. an Hash)
    # @param [String] name the name of the store
    # @return [MongoPersistedHash] a MongoDB backed Hash/object store
    def self.get_mongo_object_store( name )

    end

    # This method returns a JSON-file-backed store (i.e. persistence)
    # for a collection (i.e. an Array)
    # @param [String] name the name of the store
    # @return [JSONFilePersistedCollection] a MongoDB backed Array/collection store
    def self.get_json_collection_store( name )

    end

    # This method returns a JSON-file-backed store (i.e. persistence)
    # for a single object (i.e. an Hash)
    # @param [String] name the name of the store
    # @return [JSONFilePersistedHash] a MongoDB backed Hash/object store
    def self.get_json_object_store( name )

    end




  end

end