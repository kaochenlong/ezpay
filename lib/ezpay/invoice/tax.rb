# frozen_string_literal: true

# 應稅：taxable
# 免稅：tax_exemption
# 零稅率：tax_zero

module Ezpay
  class Invoice
    class Tax
      module TaxType
        TAXABLE = "1"
        TAX_ZERO = "2"
        TAX_EXEMPTION = "3"
        MIXED = "9"
      end

      attr_accessor :type, :rate

      def initialize(type: :taxable, rate: ENV["DEFAULT_TAX_RATE"].to_i)
        self.type = type
        @rate = type == :taxable ? rate : 0
      end

      def type=(value)
        @type = TaxType.enum(value)
      end

      # 應稅
      def taxable?
        type == TaxType::TAXABLE
      end

      # 免稅
      def tax_exemption?
        type == TaxType::TAX_EXEMPTION
      end

      # 零稅率
      def tax_zero?
        type == TaxType::TAX_ZERO
      end
    end
  end
end
