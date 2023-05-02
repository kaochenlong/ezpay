# frozen_string_literal: true

require "uri"
require "net/http"

module Ezpay
  class Invoice
    class Client
      attr_reader :merchant_id, :hash_iv, :hash_key, :end_point

      def initialize(
        merchant_id: nil,
        hash_key: nil,
        hash_iv: nil,
        end_point: nil
      )
        @merchant_id = merchant_id || ENV.fetch("EZPAY_MERCHANT_ID", nil)
        @hash_key = hash_key || ENV.fetch("EZPAY_HASH_KEY", nil)
        @hash_iv = hash_iv || ENV.fetch("EZPAY_HASH_IV", nil)
        @end_point = end_point || ENV.fetch("EZPAY_API_ENDPOINT", nil)
      end

      def ready?
        merchant_id && hash_key && hash_key
      end

      def issue_invoice!(data = {})
        uri = URI("#{end_point}/invoice_issue")
        result = Net::HTTP.post_form(uri, data)

        Ezpay::Invoice::Response.new(result.body)
      end
    end
  end
end
