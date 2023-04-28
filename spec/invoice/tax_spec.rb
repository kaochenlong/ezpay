# frozen_string_literal: true

# 稅率：tax_rate
# 應稅：taxable
# 免稅：tax_exemption
# 零稅率：tax_zero

RSpec.describe Ezpay::Invoice::Tax do
  it '建立一般應稅 Tax 物件' do
    tax = Ezpay::Invoice::Tax.new(type: :taxable, rate: 5)

    expect(tax.rate).to be 5
    expect(tax).to be_taxable
  end

  it '建立零稅率 Tax 物件' do
    tax = Ezpay::Invoice::Tax.new(type: :tax_zero, rate: 5)

    expect(tax.rate).to be 0
    expect(tax).to be_tax_zero
  end

  it '如果是免稅，稅率自動為 0' do
    tax = Ezpay::Invoice::Tax.new(type: :tax_exemption, rate: 5)

    expect(tax.rate).to be 0
    expect(tax).to be_tax_exemption
  end

  it '預設 Tax 物件為「應稅」，稅率為「5%」' do
    tax = Ezpay::Invoice::Tax.new

    expect(tax.rate).to be 5
    expect(tax.type).to eq :taxable
  end
end

# ItemName：商品名稱

# 若同時有多項商品，商品名稱之間以 | 分格，例如 商品一|商品二|商品三
# ItemCount：商品數量
# 若同時有多項商品，商品數量之間以 | 分格，例如 2|10|4
# ItemUnit：商品單位
# 範例：個、件、本、張…
# 字數限 2 個中文字或 6 個英文數字字
# 若同時有多項商品，商品單位之間以 | 分格，例如 個|個|份
# ItemPrice：商品單價
# Category 設定為 B2B 時，此參數金額為未稅金額
# Category 設定為 B2C 時，此參數金額為含稅金額
# 若同時有多項商品，商品單價之間以 | 分格，例如 100|250|1450
# 格式：純數字
# ItemAmt：商品小計：
# 計算 = 數量 x 單價
# Category 設定為 B2B 時，此參數金額為未稅金額
# Category 設定為 B2C 時，此參數金額為含稅金額
# 若同時有多項商品，商品小計之間以 | 分格，例如 100|250|1450
# 格式：純數字
