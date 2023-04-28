# frozen_string_literal: true

require "faker"

FactoryBot.define do
  factory :order_item, class: Ezpay::Invoice::OrderItem do
    name { Faker::Name.name }
    price { Faker::Number.between(from: 10, to: 500) }
    quantity { 1 }

    trait :taxable do
      tax_type { :taxable }
      tax_rate { 5 }
    end

    trait :tax_zero do
      tax_type { :tax_zero }
    end

    trait :tax_exemption do
      tax_type { :tax_exemption }
    end

    initialize_with { new(**attributes) }
  end
end
