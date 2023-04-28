# frozen_string_literal: true

RSpec.describe Ezpay::Invoice do
  context "個人發票（B2C）" do
    let(:buyer) { build(:personal_buyer) }

    it "不使用載具也不捐贈" do
      invoice = Ezpay::PersonalInvoice.new(buyer:, comment: "Hello World")

      expect(invoice.print_flag).to be true
    end

    it "發票寫了太多字的備註" do
      expect {
        Ezpay::PersonalInvoice.new(buyer:, comment: "Hello World" * 50)
      }.to raise_error Ezpay::Invoice::Error::CommentFormatError
    end

    it "使用手機條碼載具，而且不想印發票" do
      carrier = build(:barcode_carrier)

      invoice = Ezpay::PersonalInvoice.new(buyer:, carrier:, print_flag: false)
      expect(invoice.print_flag).to be false
    end

    it "使用 ezPay 載具" do
      carrier = build(:ezpay_carrier)

      invoice = Ezpay::PersonalInvoice.new(buyer:, carrier:, print_flag: false)

      expect(invoice.print_flag).to be false
      expect(invoice.buyer.email).not_to be_nil
    end

    it "愛心捐贈，想要印發票" do
      carrier = build(:donation_carrier)

      invoice = Ezpay::PersonalInvoice.new(buyer:, carrier:, print_flag: true)

      expect(invoice.print_flag).to be true
    end

    context "購買商品" do
      it "單項應稅商品" do
        taxable_item = build(:order_item)
        order = build(:order, item: taxable_item)

        invoice = Ezpay::PersonalInvoice.new(buyer:, order:)

        expect(invoice.total_amount).to be order.total_amount
      end

      it "多項應稅、免稅商品" do
        taxable_items = build_list(:order_item, 3)
        tax_exemption_items = build_list(:order_item, 2, :tax_exemption)
        order = build(:order, item: taxable_items + tax_exemption_items)

        invoice = Ezpay::PersonalInvoice.new(buyer:, order:)

        expect(invoice.total_amount).to be order.total_amount
      end
    end
  end

  context "公司發票（B2B）" do
    let(:buyer) { build(:company_buyer) }

    it "建立發票" do
      invoice = Ezpay::CompanyInvoice.new(buyer:)
      expect(invoice.print_flag).to be true
    end
  end
end
