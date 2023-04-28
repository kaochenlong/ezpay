# frozen_string_literal: true

require "faker"

FactoryBot.define do
  factory :buyer, class: Ezpay::Invoice::Buyer do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    address { Faker::Address.full_address }

    trait :personal do
      initialize_with { Ezpay::Invoice::PersonalBuyer.new(**attributes) }
    end

    trait :company do
      ubn { "88117125" }
      initialize_with { Ezpay::Invoice::CompanyBuyer.new(**attributes) }
    end

    factory :personal_buyer, traits: [:personal]
    factory :company_buyer, traits: [:company]
  end
end
