# frozen_string_literal: true

module Ezpay
  class Invoice
    class Order
      attr_reader :items
      attr_accessor :serial

      def initialize(item: nil, serial: nil)
        raise Ezpay::Invoice::Error::OrderSerialError, "需填寫訂單編號" if serial.nil?

        if serial && serial.length > 20
          raise Ezpay::Invoice::Error::OrderSerialError, "訂單編號最多 20 碼"
        end

        @items = []
        if item.is_a?(Array)
          @items = item
        elsif item
          add_item(item)
        end

        @serial = serial
      end

      def add_item(item = nil)
        @items << item if item
      end

      def add_items(*items)
        items.each { |item| add_item(item) }
      end

      def empty?
        items.empty?
      end

      def total_amount(with_tax: true)
        items.map { |item| item.total_amount(with_tax:) }.sum
      end

      def total_tax
        items.map(&:total_tax).sum
      end

      def item_names
        items.map(&:name).join("|")
      end

      def item_counts
        items.map(&:quantity).join("|")
      end

      def item_units
        items.map(&:unit).join("|")
      end

      def item_prices
        items.map(&:price).join("|")
      end

      def item_total_amounts(with_tax: true)
        items.map { |item| item.total_amount(with_tax:) }.join("|")
      end

      def item_tax_types
        items.map { |item| item.tax.type }.join("|")
      end

      # taxable/tax_zero/tax_exemption 分開計算銷售額（未稅）
      def amounts
        taxable =
          items
            .filter(&:taxable?)
            .map { |item| item.total_amount(with_tax: false) }
            .sum
        tax_zero =
          items.filter(&:tax_zero?).map { |item| item.total_amount }.sum
        tax_exemption =
          items.filter(&:tax_exemption?).map { |item| item.total_amount }.sum

        { taxable:, tax_zero:, tax_exemption: }
      end

      def same_tax_type?
        items.all? { |item| item.tax.type == items.first.tax.type }
      end
    end
  end
end
