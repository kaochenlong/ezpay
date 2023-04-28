# frozen_string_literal: true

module Ezpay
  class Invoice
    class Order
      attr_reader :items

      def initialize(item: nil)
        @items = []
        if item.is_a?(Array)
          @items = item
        elsif item
          add_item(item)
        end
      end

      def add_item(item = nil)
        @items << item if item
      end

      def empty?
        @items.empty?
      end

      def total_amount
        @items.map(&:total_amount).sum
      end
    end
  end
end
