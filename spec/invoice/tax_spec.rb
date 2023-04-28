# frozen_string_literal: true

# 應稅：taxable, 免稅：tax_exemption, 零稅率：tax_zero

RSpec.describe Ezpay::Invoice::Tax do
  it '建立一般應稅 Tax 物件' do
    tax = build(:tax)

    expect(tax.rate).not_to be 0
    expect(tax).to be_taxable
  end

  it '建立零稅率 Tax 物件' do
    tax = build(:tax, :tax_zero)

    expect(tax.rate).to be 0
    expect(tax).to be_tax_zero
  end

  it '如果是免稅，稅率自動為 0' do
    tax = build(:tax, :tax_exemption)

    expect(tax.rate).to be 0
    expect(tax).to be_tax_exemption
  end

  it '預設 Tax 物件為「應稅」，稅率為「預設稅率」' do
    tax = Ezpay::Invoice::Tax.new

    expect(tax.type).to eq :taxable
    expect(tax.rate).to be ENV['DEFAULT_TAX_RATE'].to_i
  end
end
