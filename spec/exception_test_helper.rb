module ExceptionTestHelper

  class DummyException < Exception
    def initialize(backtrace = nil)
      super
      set_backtrace(backtrace)
    end

    def message
      'Dummy Exception Message'
    end
  end

  class DummyController
    def controller_name
      'DummyController'
    end

    def action_name
      'TestAction'
    end
  end
end
