# frozen_string_literal: true

require "securerandom"

FactoryBot.define do
  factory :order, class: Ezpay::Invoice::Order do
    item { nil }
    serial { SecureRandom.alphanumeric(20).upcase }

    trait :with_item do
      item { build(:order_item) }
    end

    initialize_with { new(**attributes) }
  end
end
