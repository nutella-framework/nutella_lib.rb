require 'helper'
require 'util/mongo_persisted_collection'
require 'util/mongo_persisted_hash'
require 'util/json_file_persisted_collection'
require 'util/json_file_persisted_hash'


class TestNutellaNetApp < MiniTest::Test

  def test_mongo_persisted_collection
    # pa = MongoPersistedCollection.new 'ltg.evl.uic.edu', 'nutella_test', 'test_collection'
    # pa.push( {an: 'object'} )
    # pa.push( {another: 'object'} )
    # pa.push( {idx_2: 'object'} )
    # pa.push( {idx_3: 'object'} )
    # pa.push( {idx_4: 'object'} )
    # puts pa.length
    # p pa.replace( {ciccio: 'pasticcio'}, {ciccio: 'pasticcio'} )
    # p pa.to_a
  end


  def test_json_file_persisted_collection
    pc = JSONFilePersistedCollection 'test.json'
  end

end
