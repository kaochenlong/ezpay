# frozen_string_literal: true

RSpec.describe Ezpay::Invoice::Carrier do
  context "手機條碼" do
    it "有效的格式" do
      carrier = build(:barcode_carrier, number: "/DE689FQ")
      expect(carrier).to be_valid
    end

    it "無效的格式" do
      carrier = build(:barcode_carrier, number: "ABCDEFGH")
      expect(carrier).not_to be_valid
    end
  end

  context "自然人憑證" do
    it "有效的格式" do
      carrier = build(:certificate_carrier, number: "AB12345678901234")
      expect(carrier).to be_valid
    end

    it "無效的格式" do
      carrier = build(:certificate_carrier, number: "12345678901234GG")
      expect(carrier).not_to be_valid
    end
  end

  context "ezPay 電子發票載具" do
    it "有效的格式" do
      carrier = build(:ezpay_carrier, number: "1234")
      expect(carrier).to be_valid
    end
  end

  context "使用捐贈碼" do
    it "有效的格式（3 ~ 7 碼數字）" do
      carrier = build(:donation_carrier, number: "1234")
      expect(carrier).to be_valid
    end

    it "無效的格式" do
      carrier = build(:donation_carrier, number: "123000123")
      expect(carrier).not_to be_valid
    end
  end
end
