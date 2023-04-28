# frozen_string_literal: true

require "faker"

FactoryBot.define do
  factory :carrier, class: Ezpay::Invoice::Carrier do
    type { nil }
    number { "" }

    trait :barcode do
      type { :barcord }
      number { "/DE689FQ" }
    end

    trait :certificate do
      type { :certificate }
      number { "AB12345678901234" }
    end

    trait :ezpay do
      type { :ezpay }
      number { Faker::Lorem.characters(number: 16).upcase }
    end

    initialize_with { new(**attributes) }
  end
end
