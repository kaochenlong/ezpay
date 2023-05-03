# frozen_string_literal: true

require "vcr"

VCR.configure do |config|
  config.filter_sensitive_data("YOUR-EZPAY-MERCHANT-ID") do
    ENV["EZPAY_MERCHANT_ID"]
  end
  config.default_cassette_options = { serialize_with: :json }
  config.allow_http_connections_when_no_cassette = true
  config.cassette_library_dir = "spec/vcr_cassettes"
  config.hook_into :webmock
  config.configure_rspec_metadata!
end
