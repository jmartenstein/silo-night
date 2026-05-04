module Services
  class Show
    def self.list_for_user(user_name)
      user = ::User.find(name: user_name)
      return nil unless user
      user.shows
    end
  end
end
