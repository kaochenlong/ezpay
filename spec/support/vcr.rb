# frozen_string_literal: true

require "vcr"

VCR.configure do |c|
  c.filter_sensitive_data("YOUR-EZPAY-MERCHANT-ID") { ENV["EZPAY_MERCHANT_ID"] }
  c.default_cassette_options = { serialize_with: :json }
  c.cassette_library_dir = "spec/vcr_cassettes"
  c.hook_into :webmock
  c.configure_rspec_metadata!
end
