# frozen_string_literal: true

require 'forwardable'

module Ezpay
  module Invoice
    module Error
      class OrderItemFieldMissingError < StandardError
      end
    end
  end
end
