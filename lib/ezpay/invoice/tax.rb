# frozen_string_literal: true

# 應稅：taxable
# 免稅：tax_exemption
# 零稅率：tax_zero

module Ezpay
  module Invoice
    class Tax
      attr_accessor :type, :rate

      def initialize(type: :taxable, rate: ENV['DEFAULT_TAX_RATE'].to_i)
        @type = type
        @rate = type == :taxable ? rate : 0
      end

      # 應稅
      def taxable?
        type == :taxable
      end

      # 免稅
      def tax_exemption?
        type == :tax_exemption
      end

      # 零稅率
      def tax_zero?
        type == :tax_zero
      end
    end
  end
end
