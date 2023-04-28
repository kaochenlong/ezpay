# frozen_string_literal: true

module Ezpay
  module Invoice
    class Carrier
      attr_reader :type, :number

      def initialize(type: nil, number: nil)
        @type = type
        @number = number
      end

      def valid?
        number &&
          case type
          when :barcord
            /^\/[A-Z0-9\.\-\+]{7}$/.match?(number)
          when :certificate
            /^[A-Z]{2}[0-9]{14}$/.match?(number)
          when :ezpay
            true
          else
            false
          end
      end
    end
  end
end
