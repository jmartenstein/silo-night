module Presenters
  class User
    def initialize(user)
      @user = user
    end

    def to_h
      { name: @user.name }
    end
  end
end
