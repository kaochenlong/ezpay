# frozen_string_literal: true

require "faker"

FactoryBot.define do
  factory :carrier, class: Ezpay::Invoice::Carrier do
    type { nil }
    number { "" }

    trait :barcode do
      type { :barcode }
      initialize_with { Ezpay::Invoice::BarcodeCarrier.new("/DE689FQ") }
    end

    trait :certificate do
      type { :certificate }
      initialize_with do
        Ezpay::Invoice::CertificateCarrier.new("AB12345678901234")
      end
    end

    trait :ezpay do
      type { :ezpay }
      initialize_with do
        Ezpay::Invoice::EzPayCarrier.new(
          Faker::Lorem.characters(number: 16).upcase
        )
      end
    end

    factory :barcode_carrier, traits: [:barcode]
    factory :certificate_carrier, traits: [:certificate]
    factory :ezpay_carrier, traits: [:ezpay]

    initialize_with { new(**attributes) }
  end
end
