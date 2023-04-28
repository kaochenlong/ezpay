# frozen_string_literal: true

require "forwardable"

module Ezpay
  class Invoice
    module Error
      class OrderItemFieldMissingError < StandardError
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
