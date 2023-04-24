# frozen_string_literal: true

RSpec.describe Ezpay do
  it 'has a version number' do
    expect(Ezpay::VERSION).not_to be nil
    expect(Ezpay::API_VERSION).not_to be nil
  end
end
