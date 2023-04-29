# frozen_string_literal: true

FactoryBot.define do
  factory :invoice, class: Ezpay::Invoice do
    order { build(:order, :with_item) }

    trait :personal do
      buyer { build(:personal_buyer) }
      initialize_with { Ezpay::PersonalInvoice.new(**attributes) }
    end

    trait :company do
      buyer { build(:company_buyer) }
      initialize_with { Ezpay::CompanyInvoice.new(**attributes) }
    end

    factory :personal_invoice, traits: [:personal]
    factory :company_invoice, traits: [:company]

    initialize_with { new(**attributes) }
  end
end
