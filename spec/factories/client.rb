# frozen_string_literal: true

require "securerandom"

FactoryBot.define do
  factory :client, class: Ezpay::Invoice::Client do
    merchant_id { format("%08d", SecureRandom.random_number(10**8)) }
    hash_key { SecureRandom.alphanumeric(32) }
    hash_iv { SecureRandom.alphanumeric(16) }

    initialize_with { new(**attributes) }
  end
end
