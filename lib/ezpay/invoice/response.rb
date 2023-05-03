# frozen_string_literal: true

require "uri"
require "json"
require "digest"

module Ezpay
  class Invoice
    class Response
      attr_reader :status,
                  :message,
                  :check_code,
                  :order_serial,
                  :invoice_number,
                  :amount,
                  :transaction_number,
                  :merchant_id,
                  :nonce,
                  :qrcode

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
          @order_serial = result["MerchantOrderNo"]
          @invoice_number = result["InvoiceNumber"]
          @transaction_number = result["InvoiceTransNo"]
          @nonce = result["RandomNum"]
          @barcode = result["BarCode"]
          @amount = result["TotalAmt"]
          @merchant_id = result["MerchantID"]
          @qrcode = "#{result["QRcodeL"]}#{result["QRcodeR"]}"

          self.check_code = result["CheckCode"]
        end
      end

      def check_code=(value)
        unless valid_check_code?(value)
          raise Ezpay::Invoice::Error::CheckCodeError, "檢核碼錯誤"
        end

        @check_code = value
      end

      # -----------
      # 檢核碼規則：
      # -----------
      # 排序欄位字串並用&符號串聯起來將回傳資料其中的五個欄位，分別是
      # InvoiceTransNo(ezPay 電子發票開立序號)
      # MerchantID(商店代號)
      # MerchantOrderNo(自訂編號)
      # RandomNum(發票防偽隨機碼)
      # TotalAmt(發票金額)
      # 參數需照英文字母 A~Z 排序
      # 將串聯後的字串前後加上專屬加密 Hash IV 值與商店串接專屬加密 Hash Key 值後再使用 SHA256 編碼並轉大寫。

      def valid_check_code?(value)
        data = {
          HashIV: ENV["EZPAY_HASH_IV"],
          InvoiceTransNo: transaction_number,
          MerchantID: merchant_id,
          MerchantOrderNo: order_serial,
          RandomNum: nonce,
          TotalAmt: amount,
          HashKey: ENV["EZPAY_HASH_KEY"]
        }

        value == Digest::SHA256.hexdigest(URI.encode_www_form(data)).upcase
      end
    end
  end
end
