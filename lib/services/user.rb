module Services
  class User
    def self.create(params)
      return nil if ::User.find(name: params[:name])
      ::User.create(
        name: params[:name],
        config: {}.to_json,
        schedule: {}.to_json
      )
    end

    def self.destroy(name)
      user = ::User.find(name: name)
      return false unless user
      user.destroy
      true
    end
  end
end
