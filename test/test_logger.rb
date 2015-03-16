require 'helper'

class TestNutellaNet < MiniTest::Test

  # nutella.init( 'ltg.evl.uic.edu', 'ale_app_1', 'ale_run_1', 'ale_component_2' )
  #
  # def test_logger
  #   p nutella.log.success 'success', 401
  #   p nutella.log.info 'info', 401
  #   p nutella.log.warn 'warn', 401
  #   p nutella.log.error 'error', 401
  #   p nutella.log.debug 'debug', 401
  # end


  nutella.app.init( 'ltg.evl.uic.edu', 'ale_app_1', 'ale_component_2' )

  def test_logger
    p nutella.app.log.success 'success', 401
    p nutella.app.log.info 'info', 401
    p nutella.app.log.warn 'warn', 401
    p nutella.app.log.error 'error', 401
    p nutella.app.log.debug 'debug', 401
  end

end