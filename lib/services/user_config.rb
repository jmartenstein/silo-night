require 'json'

module Services
  class UserConfig
    def self.update_for_user(user, config_params)
      current_config = JSON.parse(user.config || "{}")
      updated_config = current_config.merge(config_params)
      
      user.update(config: updated_config.to_json)
      true
    end

    def self.get_for_user(user)
      JSON.parse(user.config || "{}")
    end
  end
end
