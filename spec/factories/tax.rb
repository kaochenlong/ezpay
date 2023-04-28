# frozen_string_literal: true

FactoryBot.define do
  factory :tax, class: Ezpay::Invoice::Tax do
    type { :taxable }
    rate { 5 }

    trait :tax_zero do
      type { :tax_zero }
      rate { 0 }
    end

    trait :tax_exemption do
      type { :tax_exemption }
      rate { 0 }
    end
  end
end
