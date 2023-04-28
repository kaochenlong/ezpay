# frozen_string_literal: true

%w[
  ezpay/version
  ezpay/invoice/error
  ezpay/invoice/client
  ezpay/invoice/tax
  ezpay/invoice/order
  ezpay/invoice/order_item
].each do |mod|
  require mod
rescue LoadError
end
