# frozen_string_literal: true

RSpec.describe Ezpay::Invoice do
  context "個人發票（B2C）" do
    it "不使用載具也不捐贈" do
      buyer = build(:personal_buyer)

      invoice = Ezpay::PersonalInvoice.new(buyer:, comment: "Hello World")

      expect(invoice.print_flag).to be true
    end

    it "發票寫了太多字的備註" do
      buyer = build(:personal_buyer)

      expect {
        Ezpay::PersonalInvoice.new(buyer:, comment: "Hello World" * 50)
      }.to raise_error Ezpay::Invoice::Error::CommentFormatError
    end

    it "使用手機條碼載具，而且不想印發票" do
      buyer = build(:personal_buyer)
      carrier = build(:barcode_carrier)

      invoice = Ezpay::PersonalInvoice.new(buyer:, carrier:, print_flag: false)
      expect(invoice.print_flag).to be false
    end

    it "使用 ezPay 載具" do
      buyer = build(:personal_buyer)
      carrier = build(:ezpay_carrier)

      invoice = Ezpay::PersonalInvoice.new(buyer:, carrier:, print_flag: false)

      expect(invoice.print_flag).to be false
      expect(invoice.buyer.email).not_to be_nil
    end

    it "愛心捐贈，想要印發票" do
      buyer = build(:personal_buyer)
      carrier = build(:donation_carrier)

      invoice = Ezpay::PersonalInvoice.new(buyer:, carrier:, print_flag: true)

      expect(invoice.print_flag).to be true
    end
  end

  context "公司發票（B2B）" do
    it "建立發票" do
      buyer = build(:company_buyer)

      invoice = Ezpay::CompanyInvoice.new(buyer:)
      expect(invoice.print_flag).to be true
    end
  end
end
