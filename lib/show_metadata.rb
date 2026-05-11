require 'sequel'
require 'json'

# Load database configuration
db_url = ENV['DATABASE_URL'] || (ENV['RACK_ENV'] == 'test' ? 'sqlite://data/test.db' : 'sqlite://data/silo_night.db')
Sequel.connect(db_url)

class ShowMetadata < Sequel::Model(:show_metadata)
  many_to_one :show
  plugin :timestamps, update_on_create: true
  
  # Configure JSON serialization for the payload column
  plugin :serialization, :json, :payload

  def validate
    super
    errors.add(:provider_name, 'is required') if provider_name.nil? || provider_name.empty?
    errors.add(:external_id, 'is required') if external_id.nil? || external_id.empty?
  end

  def self.upsert(provider_name:, external_id:, payload:, show_id: nil)
    retries = 2
    begin
      metadata = find(provider_name: provider_name, external_id: external_id)
      if metadata
        metadata.update(payload: payload, show_id: show_id || metadata.show_id)
      else
        create(provider_name: provider_name, external_id: external_id, payload: payload, show_id: show_id)
      end
    rescue Sequel::UniqueConstraintViolation
      retries -= 1
      retry if retries > 0
      raise
    end
  end
end
