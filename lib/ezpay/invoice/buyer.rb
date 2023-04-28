# frozen_string_literal: true

require "ezpay/company/vat_validator"

module Ezpay
  class Invoice
    class Buyer
      attr_accessor :name, :ubn, :email, :address

      def initialize(name:, type:, ubn: nil, email: nil, address: nil)
        @name = name
        @type = type
        @ubn = ubn
        @email = email
        @address = address
      end

      def company?
        @type == :company
      end

      def personal?
        @type == :personal
      end

      def valid?
        false
      end
    end

    class CompanyBuyer < Buyer
      include Ezpay::Company::Validator

      def initialize(name: nil, ubn:, email: nil, address: nil)
        if valid_vat_number?(ubn)
          if name && name.length > 60
            raise Ezpay::Invoice::Error::BuyerNameFormatError, "買受人姓名最多 30 個字"
          end

          name = ubn if name.to_s.empty?
          super(type: :company, ubn:, name:, email:, address:)
        else
          raise Ezpay::Invoice::Error::CompanyUBNFormatError
        end
      end

      def valid?
        valid_vat_number?(ubn)
      end
    end

    class PersonalBuyer < Buyer
      def initialize(name:, email: nil, address: nil)
        if name && name.length > 30
          raise Ezpay::Invoice::Error::BuyerNameFormatError, "買受人姓名最多 30 個字"
        end

        super(type: :personal, name:, email:, address:)
      end
    end
  end
end
