# frozen_string_literal: true

RSpec.describe Ezpay::Invoice::Order do
  let(:order) { build(:order) }
  let(:item) { build(:order_item, price: 100) }

  context "只有一個訂單項目 OrderItem" do
    it "建立空訂單物件" do
      expect(order).to be_empty
    end

    it "訂單編號必填" do
      expect {
        build(:order, serial: nil)
      }.to raise_error Ezpay::Invoice::Error::OrderSerialError
    end

    it "在 new 訂單的時候一併設定購買項目" do
      order = build(:order, item:)

      expect(order).not_to be_empty
      expect(order.items.count).to be 1
    end

    it "可以顯示購買項目名稱、數量、單價、單位及課稅別" do
      order = build(:order, item:)

      expect(order.item_names).to eq item.name
      expect(order.item_counts).to eq item.quantity.to_s
      expect(order.item_units).to eq item.unit
      expect(order.item_prices).to eq item.price.to_s
      expect(order.item_tax_types).to eq item.tax.type.to_s
    end

    it "或後續幫訂單新增一個訂單項目" do
      order.add_item(item)

      expect(order).not_to be_empty
      expect(order.items.count).to be 1
    end

    context "可計算訂單總金額" do
      let(:item) { build(:order_item, price: 150, quantity: 2) }

      it "應稅" do
        order.add_item(item)

        expect(order.total_amount).to be 315
      end

      it "免稅" do
        item.set_tax(type: :tax_exemption)

        order.add_item(item)

        expect(order.total_amount).to be 300
      end
    end
  end

  context "有多個購買項目" do
    let(:item1) { build(:order_item, price: 150, quantity: 2) }
    let(:item2) { build(:order_item, price: 200, quantity: 3) }
    let(:item3) { build(:order_item, price: 250, quantity: 2) }

    it "可在 new 訂單的時候設定多個購買項目" do
      items = [item1, item2]
      order = build(:order, item: items)

      expect(order).not_to be_empty
      expect(order.items.count).to be 2
    end

    it "或是後續再加進來" do
      expect(order).to be_empty

      order.add_items(item1, item2)

      expect(order).not_to be_empty
      expect(order.items.count).to be 2
    end

    it "可以顯示購買項目名稱、數量、單價、單位及課稅別" do
      order.add_items(item1, item2)

      expect(order.item_names).to eq "#{item1.name}|#{item2.name}"
      expect(order.item_counts).to eq "#{item1.quantity}|#{item2.quantity}"
      expect(order.item_units).to eq "#{item1.unit}|#{item2.unit}"
      expect(order.item_prices).to eq "#{item1.price}|#{item2.price}"
      expect(order.item_tax_types).to eq "#{item1.tax.type}|#{item2.tax.type}"
    end

    context "可計算總金額" do
      it "都是應稅項目" do
        order.add_items(item1, item2)

        # (150 x 2) x 1.05 = 315
        # (200 x 3) x 1.05 = 630
        # 315 + 630 = 945
        expect(order.total_amount).to be 945
        expect(order.total_amount(with_tax: false)).to be 900
        expect(order.total_tax).to be 45
      end

      it "都是免稅項目" do
        item1.set_tax(type: :tax_exemption)
        item2.set_tax(type: :tax_exemption)

        order.add_items(item1, item2)

        # (150 x 2) = 300
        # (200 x 3) = 600
        # 300 + 600 = 900
        expect(order.total_amount).to be 900
        expect(order.total_amount(with_tax: true)).to be 900
        expect(order.total_tax).to be 0
      end

      it "應稅、免稅混合" do
        item2.set_tax(type: :tax_exemption)

        order.add_items(item1, item2)

        # (150 x 2) x 1.05 = 315
        # (200 x 3) = 600
        # 315 + 600 = 915
        expect(order.total_amount).to be 915
        expect(order.total_amount(with_tax: false)).to be 900
        expect(order.total_tax).to be 15
      end

      it "顯示分別計算銷售額" do
        item1.set_tax(type: :taxable)
        item2.set_tax(type: :tax_zero)
        item3.set_tax(type: :tax_exemption)

        order.add_items(item1, item2, item3)

        expect_amounts = { taxable: 300, tax_zero: 600, tax_exemption: 500 }
        expect(order.amounts).to eq expect_amounts
      end

      context "稅別" do
        it "相同稅別" do
          item1.set_tax(type: :tax_exemption)
          item2.set_tax(type: :tax_exemption)

          order.add_items(item1, item2)

          expect(order).to be_same_tax_type
        end

        it "不同稅別" do
          item1.set_tax(type: :taxable)
          item2.set_tax(type: :tax_exemption)

          order.add_items(item1, item2)

          expect(order).not_to be_same_tax_type
        end
      end
    end
  end
end
