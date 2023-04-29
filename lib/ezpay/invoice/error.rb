# frozen_string_literal: true

require "forwardable"

module Ezpay
  class Invoice
    module Error
      class EnumMissingError < StandardError
      end

      class OrderItemFieldMissingError < StandardError
      end

      class OrderSerialError < StandardError
      end

      class IssueDateError < StandardError
      end

      class CompanyUBNFormatError < StandardError
      end

      class BuyerError < StandardError
      end

      class BuyerNameFormatError < StandardError
      end

      class CarrierError < StandardError
      end

      class CommentFormatError < StandardError
      end
    end
  end
end
