# frozen_string_literal: true

RSpec.describe Ezpay do
  it "有正確的版本號碼" do
    expect(Ezpay::VERSION).not_to be nil
    expect(Ezpay::API_VERSION).not_to be nil
  end
end
