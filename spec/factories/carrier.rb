# frozen_string_literal: true

require "faker"

FactoryBot.define do
  factory :carrier, class: Ezpay::Invoice::Carrier do
    trait :barcode do
      number { "/DE689FQ" }

      initialize_with do
        Ezpay::Invoice::BarcodeCarrier.new(attributes[:number])
      end
    end

    trait :certificate do
      number { "AB12345678901234" }

      initialize_with do
        Ezpay::Invoice::CertificateCarrier.new(attributes[:number])
      end
    end

    trait :ezpay do
      number { Faker::Lorem.characters(number: 16).upcase }

      initialize_with { Ezpay::Invoice::EzPayCarrier.new(attributes[:number]) }
    end

    trait :donation do
      number { "123" }

      initialize_with do
        Ezpay::Invoice::DonationCarrier.new(attributes[:number])
      end
    end

    factory :barcode_carrier, traits: [:barcode]
    factory :certificate_carrier, traits: [:certificate]
    factory :ezpay_carrier, traits: [:ezpay]
    factory :donation_carrier, traits: [:donation]

    initialize_with { new(**attributes) }
  end
end
