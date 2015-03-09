require 'json'
require 'pstore'
require 'fileutils'
require 'thread'

module Nutella

  # Implements basic run-dependent persistence for nutella bots.
  module Persist

    # This module exposes a single method to retrieve a JSONStore
    def Persist.getJsonStore(file_name)
      dir = file_name[0..file_name.rindex('/')]
      file = file_name[file_name.rindex('/')..file_name.length-1]
      new_dir = dir + Nutella.run_id
      FileUtils.mkdir_p new_dir
      JSONStore.new(new_dir + file)
    end

  end

# JSONStore provides the same functionality as PStore, except it uses JSON
# to dump objects instead of Marshal.
# Example use:
#   store = nutella.persist.getJsonStore("json_store/json_test.json")
#   # Write
#   store.transaction { store["key"]="value" }
#   # Read
#   value = store.transaction { store["key"] }
#   puts value # prints "value"
#   # Dump the whole store
#   hash = store.transaction { store.to_h }
#   p hash # prints {"key" => "value"}

  class JSONStore < PStore

    def initialize(path)
      super
      @semaphore = Mutex.new
    end

    def dump(table)
      table.to_json
    end

    def load(content)
      JSON.parse(content)
    end

    def transaction(read_only=false, &block)
      @semaphore.synchronize {
        # access shared resource
        super
      }
    end

    # Dumps the whole store to hash
    # example:
    # store = JSONStore.new("my_file.json")
    # hash = store.transaction { store.to_h }
    def to_h
      @table
    end

    def merge!( hash )
      @table.merge!(hash)
    end


    def marshal_dump_supports_canonical_option?
      false
    end

    EMPTY_MARSHAL_DATA = {}.to_json
    EMPTY_MARSHAL_CHECKSUM = Digest::MD5.digest(EMPTY_MARSHAL_DATA)
    def empty_marshal_data
      EMPTY_MARSHAL_DATA
    end
    def empty_marshal_checksum
      EMPTY_MARSHAL_CHECKSUM
    end
  end


end