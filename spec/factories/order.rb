# frozen_string_literal: true

require "faker"

FactoryBot.define do
  factory :order, class: Ezpay::Invoice::Order do
    item { nil }
    serial { nil }

    initialize_with { new(**attributes) }
  end
end
