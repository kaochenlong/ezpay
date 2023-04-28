# frozen_string_literal: true

module Ezpay
  class Invoice
    class Carrier
      attr_accessor :type, :number

      def initialize(type: nil, number: nil)
        @type = type
        @number = number
      end

      def valid?
        false
      end
    end

    class BarcodeCarrier < Carrier
      def initialize(number)
        super(type: :barcode, number: number)
      end

      def valid?
        number && /^\/[A-Z0-9\.\-\+]{7}$/.match?(number)
      end
    end

    class CertificateCarrier < Carrier
      def initialize(number)
        super(type: :certificate, number: number)
      end

      def valid?
        number && /^[A-Z]{2}[0-9]{14}$/.match?(number)
      end
    end

    class EzPayCarrier < Carrier
      def initialize(number)
        super(type: :ezpay, number: number)
      end

      def valid?
        number && number.length > 0
      end
    end

    class DonationCarrier < Carrier
      def initialize(number)
        super(type: :donation, number: number)
      end

      def valid?
        number && /^[\d]{3,7}$/.match?(number)
      end
    end
  end
end
