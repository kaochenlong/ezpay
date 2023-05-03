# frozen_string_literal: true

require "forwardable"

module Ezpay
  class Invoice
    module Error
      class EnumMissingError < StandardError
      end

      # Order Errors
      class OrderError < StandardError
      end

      class OrderItemFieldMissingError < OrderError
      end

      class OrderSerialError < OrderError
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

      class MixedTaxError < StandardError
      end

      class ClientError < StandardError
      end

      class CheckCodeError < StandardError
      end
    end
  end
end
