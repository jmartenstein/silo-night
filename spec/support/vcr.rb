require 'vcr'

VCR.configure do
 |config|
  config.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  config.hook_into :webmock
  config.filter_sensitive_data('<TMDB_API_KEY>') { ENV['TMDB_API_KEY'] }
  config.filter_sensitive_data('<TVMAZE_API_KEY>') { ENV['TVMAZE_API_KEY'] }
  config.configure_rspec_metadata!
end


