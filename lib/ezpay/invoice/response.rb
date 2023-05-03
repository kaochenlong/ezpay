# frozen_string_literal: true

require "json"

module Ezpay
  class Invoice
    class Response
      attr_reader :status,
                  :message,
                  :check_code,
                  :order_serial,
                  :invoice_number,
                  :nonce

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

        if success?
          result = JSON.parse(data["Result"])
          @check_code = result["CheckCode"]
          @order_serial = result["MerchantOrderNo"]
          @invoice_number = result["InvoiceNumber"]
          @transaction_number = result["InvoiceTransNo"]
          @nonce = result["RandomNum"]
          p result
        end

        # {""=>"", ""=>"", "d"=>"", "TotalAmt"=>405, "InvoiceTransNo"=>"23050218454878855", "RandomNum"=>"4213", "CreateTime"=>""}
        # @result = data["Result"]

        # @result="{\"CheckCode\":\"747C1587FBC6A88F6D9B737408FF4690B77BC25596700CE6457083DB00C8232C\",\"MerchantID\":\"34884285\",\"MerchantOrderNo\":\"JVETHSXIVSZGFNFDRBKQ\",\"InvoiceNumber\":\"\",\"TotalAmt\":407,\"InvoiceTransNo\":\"23050218435899769\",\"RandomNum\":\"2434\",\"CreateTime\":\"\"}">
      end
    end
  end
end
