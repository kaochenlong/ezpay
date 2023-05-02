# frozen_string_literal: true

module Ezpay
  class Invoice
    class Client
      def initialize(merchant_id: nil, hash_key: nil, hash_iv: nil)
        @merchant_id = merchant_id || ENV.fetch("EZPAY_MERCHANT_ID", nil)
        @hash_key = hash_key || ENV.fetch("EZPAY_HASH_KEY", nil)
        @hash_iv = hash_iv || ENV.fetch("EZPAY_HASH_IV", nil)
      end

      def ready?
        @merchant_id && @hash_key && @hash_key
      end
    end
  end
end
