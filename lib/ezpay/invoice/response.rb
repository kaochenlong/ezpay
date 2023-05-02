# frozen_string_literal: true

require "json"

module Ezpay
  class Invoice
    class Response
      attr_reader :status, :message, :result

      def initialize(response = nil)
        raise Ezpay::Invoice::Error::ResponseError, "回應內容有誤" if response.nil?

        self.response = response
      end

      def success?
        @status == "SUCCESS"
      end

      private

      def response=(value)
        data = JSON.parse(value)

        @status = data["Status"]
        @message = data["Message"]
        @result = data["Result"]
      end
    end
  end
end
