require 'helper'

require 'util/mongo_persisted_collection'
require 'util/json_file_persisted_collection'
require 'util/mongo_persisted_hash'
require 'util/json_file_persisted_hash'


class TestNutellaNetApp < MiniTest::Test

  # def test_mongo_persisted_collection
  #   pa = MongoPersistedCollection.new 'ltg.evl.uic.edu', 'nutella_test', 'test_collection'
  #   pa.push( {an: 'object'} )
  #   pa.push( {another: 'object'} )
  #   pa.push( {idx_2: 'object'} )
  #   pa.push( {idx_3: 'object'} )
  #   pa.push( {idx_4: 'object'} )
  #   p pa.replace( {ciccio: 'pasticcio'}, {ciccio: 'pasticcio'} )
  #   p pa.length
  #   p pa.to_a
  # end


  # def test_json_file_persisted_collection
  #   pc = JSONFilePersistedCollection.new 'test.json'
  #   # pc.push({an: 'object'}).push({another: 'object'})
  #   p pc.length
  #   p pc.to_a
  #   p pc.replace({'an' => 'object'}, {'with_another' => 'object'})
  # end


  # def test_json_file_persisted_hash
  #   ph = JSONFilePersistedHash.new 'test.json'
  #   p ph['test']
  #   p ph['test'] = 'yes'
  #   p ph.delete_key_value? 'test'
  #   p ph.add_key_value? 'test', 'pippo'
  # end


  # def test_mongo_persisted_hash
  #   ph = MongoPersistedHash.new 'ltg.evl.uic.edu', 'nutella_test', 'hash_test', 'my_hash'
  #   ph['ciao'] = 'bello'
  #   p ph.to_h
  # end

end
