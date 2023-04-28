# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :order_item, class: Ezpay::Invoice::OrderItem do
    name { Faker::Name.name }
    price { Faker::Number.between(from: 10, to: 500) }
    quantity { 1 }

    initialize_with { new(**attributes) }
  end
end
