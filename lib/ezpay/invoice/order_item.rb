# frozen_string_literal: true

require "forwardable"

module Ezpay
  module Invoice
    class OrderItem
      extend Forwardable
      attr_reader :name, :quantity, :price, :unit, :tax

      def initialize(
        name: nil,
        price: nil,
        quantity: 1,
        unit: ENV["DEFAULT_UNIT"],
        tax_type: :taxable,
        tax_rate: ENV["DEFAULT_TAX_RATE"].to_i
      )
        if name.nil?
          raise Ezpay::Invoice::Error::OrderItemFieldMissingError,
                "item name is required"
        end

        if price.nil?
          raise Ezpay::Invoice::Error::OrderItemFieldMissingError,
                "item price is required"
        end

        @name = name
        @quantity = quantity
        @price = price
        @unit = unit
        @tax = Tax.new(type: tax_type, rate: tax_rate)
      end

      # 法規名稱：加值型及非加值型營業稅法
      # 第 14 條 營業人銷售貨物或勞務，除本章第二節另有規定外，均應就銷售額，分別按第七條或第十條規定計算其銷項稅額
      # 尾數不滿通用貨幣一元者，按四捨五入計算。
      def total_amount
        if taxable?
          (quantity * price * ((100 + tax_rate) / 100.0)).round
        else
          quantity * price
        end
      end

      def tax_rate
        @tax.rate
      end

      def tax_rate=(new_tax_rate = 0)
        @tax.rate = new_tax_rate if new_tax_rate.positive?
      end

      # 設定稅別
      def set_tax(type:, rate: 0)
        @tax.type = type

        @tax.rate = (%i[tax_exemption tax_zero].include?(type) ? 0 : rate)
      end

      def_delegators :@tax, :taxable?, :tax_exemption?, :tax_zero?
    end
  end
end
