# frozen_string_literal: true

RSpec.describe Ezpay::Invoice::OrderItem do
  context "建立訂單物件" do
    it "可以建立訂單物件，並計算該項金額小計" do
      item =
        Ezpay::Invoice::OrderItem.new(
          name: "為你自己學 Git",
          quantity: 2,
          price: 150,
          unit: "個"
        )

      expect(item.total_amount).to be 300
      expect(item.unit).to eq "個"
    end
  end

  context "數量及單位" do
    it "如果沒填寫數量，預設數量 1，單位「件」" do
      item = Ezpay::Invoice::OrderItem.new(name: "Hello World", price: 100)

      expect(item.quantity).to be 1
      expect(item.unit).to eq "件"
    end
  end

  context "稅別" do
    it "如果沒填寫稅別，預設為「應稅」，稅率為「預設稅率」" do
      item = Ezpay::Invoice::OrderItem.new(name: "Hello World", price: 100)

      expect(item).to be_taxable
      expect(item.tax_rate).to be 5
    end

    it "可改變特定 item 的稅率" do
      item = Ezpay::Invoice::OrderItem.new(name: "Hello World", price: 100)

      item.tax_rate = 8

      expect(item).to be_taxable
      expect(item.tax_rate).to be 8
    end

    it "可變更稅別" do
      item = Ezpay::Invoice::OrderItem.new(name: "Hello World", price: 100)
      expect(item).to be_taxable

      item.set_tax(type: :tax_exemption)
      expect(item).to be_tax_exemption
      expect(item.tax_rate).to be 0

      item.set_tax(type: :tax_zero)
      expect(item).to be_tax_zero
      expect(item.tax_rate).to be 0

      item.set_tax(type: :taxable, rate: 8)
      expect(item).to be_taxable
      expect(item.tax_rate).to be 8
    end
  end
end
