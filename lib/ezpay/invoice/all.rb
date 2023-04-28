# frozen_string_literal: true

%w[ezpay/version ezpay/invoice/client ezpay/invoice/tax].each do |mod|
  require mod
rescue LoadError
end
