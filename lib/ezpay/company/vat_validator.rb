# frozen_string_literal: true

module Ezpay
  module Company
    module Validator
      def valid_vat_number?(vat)
        validators = [1, 2, 1, 2, 1, 2, 4, 1]

        check_sum =
          vat
            .chars
            .map(&:to_i)
            .zip(validators)
            .map { |a, b| number_reducer(a * b) }

        if vat[6] == "7"
          check_sum[6] = 0
          return [0, 1].include?(check_sum.sum % 5)
        end

        check_sum.sum % 5 == 0
      end

      private

      def number_reducer(num)
        return num if num < 10
        number_reducer(num.digits.sum)
      end
    end
  end
end
