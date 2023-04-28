# frozen_string_literal: true

require 'faker'

FactoryBot.define do
  factory :order, class: Ezpay::Invoice::Order do
    item { nil }

    trait :one_item do
    end

    trait :multiple_items do
    end

    initialize_with { new(**attributes) }
  end
end
