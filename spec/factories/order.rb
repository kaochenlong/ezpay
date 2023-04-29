# frozen_string_literal: true

require "faker"

FactoryBot.define do
  factory :order, class: Ezpay::Invoice::Order do
    item { nil }
    serial { nil }

    trait :with_item do
      item { build(:order_item) }
    end

    initialize_with { new(**attributes) }
  end
end
