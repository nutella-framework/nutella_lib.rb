require 'helper'

class TestNutellaLib < MiniTest::Test

  def test_that_kernel_extension_works
    assert_instance_of Nutella::Core, nutella
  end



end
