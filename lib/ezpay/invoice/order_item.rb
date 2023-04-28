# frozen_string_literal: true

require "forwardable"

module Ezpay
  module Invoice
    class OrderItem
      extend Forwardable
      attr_reader :name, :quantity, :price, :unit, :tax

      def initialize(
        name:,
        quantity: 1,
        price:,
        unit: ENV["DEFAULT_UNIT"],
        tax_type: :taxable,
        tax_rate: ENV["DEFAULT_TAX_RATE"].to_i
      )
        @name = name
        @quantity = quantity
        @price = price
        @unit = unit
        @tax = Tax.new(type: tax_type, rate: tax_rate)
      end

      def total_amount
        quantity * price
      end

      def tax_rate
        @tax.rate
      end

      def tax_rate=(new_tax_rate = 0)
        @tax.rate = new_tax_rate if new_tax_rate > 0
      end

      # 設定稅別
      def set_tax(type:, rate: 0)
        @tax.type = type

        if %i[tax_exemption tax_zero].include?(type)
          @tax.rate = 0
        else
          @tax.rate = rate
        end
      end

      def_delegators :@tax, :taxable?, :tax_exemption?, :tax_zero?
    end
  end
end
