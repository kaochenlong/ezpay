# frozen_string_literal: true

require "forwardable"

module Ezpay
  class Invoice
    module Error
      class OrderItemFieldMissingError < StandardError
      end
      class CompanyUBNFormatError < StandardError
      end
      class BuyerNameFormatError < StandardError
      end
    end
  end
end
