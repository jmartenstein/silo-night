require 'show_metadata'
require 'rspec'

describe ShowMetadata do
  before(:each) do
    # Clear the table before each test
    ShowMetadata.dataset.delete
  end

  it "is invalid without provider_name" do
    m = ShowMetadata.new(external_id: "123")
    expect(m.valid?).to be false
    expect(m.errors[:provider_name]).to include('is required')
  end

  it "is invalid without external_id" do
    m = ShowMetadata.new(provider_name: "TMDB")
    expect(m.valid?).to be false
    expect(m.errors[:external_id]).to include('is required')
  end

  it "is valid with both provider_name and external_id" do
    m = ShowMetadata.new(provider_name: "TMDB", external_id: "123")
    expect(m.valid?).to be true
  end

  it "serializes the payload as JSON" do
    payload = { "foo" => "bar", "baz" => 123 }
    m = ShowMetadata.new(provider_name: "TMDB", external_id: "123", payload: payload)
    m.save
    
    # Reload from database to verify serialization
    m2 = ShowMetadata.find(id: m.id)
    expect(m2.payload).to eq(payload)
    expect(m2.payload["foo"]).to eq("bar")
  end

  it "enforces unique provider_name and external_id" do
    ShowMetadata.create(provider_name: "TMDB", external_id: "123")
    expect {
      ShowMetadata.create(provider_name: "TMDB", external_id: "123")
    }.to raise_error(Sequel::UniqueConstraintViolation)
  end

  it "updates timestamps automatically" do
    m = ShowMetadata.create(provider_name: "TMDB", external_id: "123")
    expect(m.created_at).not_to be_nil
    expect(m.updated_at).not_to be_nil
    
    old_updated_at = m.updated_at
    sleep 1 if ENV['RACK_ENV'] == 'test' # Ensure time difference
    
    m.update(payload: { "test" => true })
    expect(m.updated_at).to be > old_updated_at
  end

  describe ".upsert" do
    it "creates a new record if it doesn't exist" do
      expect {
        ShowMetadata.upsert(provider_name: "TMDB", external_id: "456", payload: { "name" => "New Show" })
      }.to change { ShowMetadata.count }.by(1)
      
      m = ShowMetadata.find(provider_name: "TMDB", external_id: "456")
      expect(m.payload["name"]).to eq("New Show")
    end

    it "updates an existing record if it exists" do
      ShowMetadata.create(provider_name: "TMDB", external_id: "456", payload: { "name" => "Old Name" })
      
      expect {
        ShowMetadata.upsert(provider_name: "TMDB", external_id: "456", payload: { "name" => "New Name" })
      }.not_to change { ShowMetadata.count }
      
      m = ShowMetadata.find(provider_name: "TMDB", external_id: "456")
      expect(m.payload["name"]).to eq("New Name")
    end
  end
end
