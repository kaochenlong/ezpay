# frozen_string_literal: true

module Ezpay
  class Invoice
    class Carrier
      module CarrierType
        BARCODE = "0"
        CERTIFICATE = "1"
        EZPAY = "2"
        DONATION = "9"
      end

      attr_reader :type, :number

      def initialize(type:, number:)
        self.type = type
        @number = number
      end

      def type=(value)
        @type = CarrierType.enum(value)
      end

      def valid?
        false
      end
    end

    class BarcodeCarrier < Carrier
      def initialize(number)
        super(type: :barcode, number:)
      end

      def valid?
        number && /^\/[A-Z0-9\.\-\+]{7}$/.match?(number)
      end
    end

    class CertificateCarrier < Carrier
      def initialize(number)
        super(type: :certificate, number:)
      end

      def valid?
        number && /^[A-Z]{2}[0-9]{14}$/.match?(number)
      end
    end

    class EzPayCarrier < Carrier
      def initialize(number)
        super(type: :ezpay, number:)
      end

      def valid?
        number && number.length > 0
      end
    end

    class DonationCarrier < Carrier
      def initialize(number)
        super(type: :donation, number:)
      end

      def valid?
        number && /^[\d]{3,7}$/.match?(number)
      end
    end
  end
end
