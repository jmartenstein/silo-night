module Presenters
  class Error
    def initialize(message, code)
      @message = message
      @code = code
    end

    def to_h
      {
        error: {
          message: @message,
          code: @code
        }
      }
    end

    def to_json(*_args)
      to_h.to_json
    end
  end
end
