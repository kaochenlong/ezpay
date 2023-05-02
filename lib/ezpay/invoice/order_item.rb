# frozen_string_literal: true

require "forwardable"

module Ezpay
  class Invoice
    class OrderItem
      extend Forwardable
      attr_reader :name, :quantity, :unit, :tax

      def initialize(
        name: nil,
        price: nil,
        quantity: 1,
        unit: ENV.fetch("DEFAULT_UNIT", nil),
        tax_type: :taxable,
        tax_rate: ENV["DEFAULT_TAX_RATE"].to_i
      )
        if name.nil?
          raise Ezpay::Invoice::Error::OrderItemFieldMissingError, "缺少品項名稱"
        end

        if price.nil?
          raise Ezpay::Invoice::Error::OrderItemFieldMissingError, "缺少品項售價"
        end

        self.name = name
        @quantity = quantity
        @price = price
        @unit = unit
        @tax = Tax.new(type: tax_type, rate: tax_rate)
      end

      def price(with_tax: false)
        if with_tax && taxable?
          (@price * ((100 + tax.rate) / 100.0)).round
        else
          @price
        end
      end

      # 法規名稱：加值型及非加值型營業稅法
      # 第 14 條 營業人銷售貨物或勞務，除本章第二節另有規定外，均應就銷售額
      # 分別按第七條或第十條規定計算其銷項稅額，尾數不滿通用貨幣一元者，按四捨五入計算。
      def total_amount(with_tax: true)
        if taxable? && with_tax
          (quantity * price * ((100 + tax_rate) / 100.0)).round
        else
          quantity * price
        end
      end

      def total_tax
        return (quantity * price * (tax_rate / 100.0)).round if taxable?
        0
      end

      def tax_rate
        @tax.rate
      end

      # 設定稅別
      def set_tax(type:, rate: 0)
        @tax.type = type

        @tax.rate = (%i[tax_exemption tax_zero].include?(type) ? 0 : rate)
      end

      def_delegators :@tax, :taxable?, :tax_exemption?, :tax_zero?

      # setters
      def tax_rate=(new_tax_rate = 0)
        @tax.rate = new_tax_rate if new_tax_rate.positive?
      end

      def name=(value)
        @name = value.gsub("|", "-")
      end
    end
  end
end
