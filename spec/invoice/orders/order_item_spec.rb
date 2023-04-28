# frozen_string_literal: true

RSpec.describe Ezpay::Invoice::OrderItem do
  let(:item) { build(:order_item, price: 100) }

  context '建立訂單物件' do
    it '可以建立訂單物件' do
      item =
        Ezpay::Invoice::OrderItem.new(
          name: '為你自己學 Git',
          quantity: 2,
          price: 150,
          unit: '個'
        )

      expect(item.unit).to eq '個'
      expect(item.price).to be 150
      expect(item.quantity).to be 2
    end

    it '沒填寫必填品項及價錢會拋出錯誤' do
      expect { Ezpay::Invoice::OrderItem.new }.to raise_error(
        Ezpay::Invoice::Error::OrderItemFieldMissingError
      )
    end
  end

  context '數量及單位' do
    it '如果沒填寫數量，預設數量 1，單位「件」' do
      expect(item.quantity).to be 1
      expect(item.unit).to eq '件'
    end
  end

  context '稅別' do
    it '如果沒填寫稅別，預設為「應稅」，稅率為「預設稅率」' do
      expect(item).to be_taxable
      expect(item.tax_rate).to be 5
    end

    it '可改變特定 item 的稅率' do
      item.tax_rate = 8

      expect(item).to be_taxable
      expect(item.tax_rate).to be 8
    end

    it '可變更稅別' do
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

    context '可依據不同稅別計算小計金額' do
      let(:item) { build(:order_item, price: 120, quantity: 2) }

      it '應稅' do
        expect(item.total_amount).to be 240 *
                                        (100 + ENV['DEFAULT_TAX_RATE'].to_i) / 100
      end

      it '免稅及零稅率' do
        item.set_tax(type: :tax_exemption)
        expect(item.total_amount).to be 240

        item.set_tax(type: :tax_zero)
        expect(item.total_amount).to be 240
      end
    end
  end
end
