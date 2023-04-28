# frozen_string_literal: true

RSpec.describe Ezpay::Invoice::Carrier do
  context "手機條碼" do
    it "有效的格式" do
      carrier = build(:carrier, :barcode, number: "/DE689FQ")
      expect(carrier).to be_valid
    end

    it "無效的格式" do
      carrier = build(:carrier, :barcode, number: "ABCDEFGH")
      expect(carrier).not_to be_valid
    end
  end

  context "自然人憑證" do
    it "有效的格式" do
      carrier = build(:carrier, :certificate, number: "AB12345678901234")
      expect(carrier).to be_valid
    end

    it "無效的格式" do
      carrier = build(:carrier, :certificate, number: "12345678901234GG")
      expect(carrier).not_to be_valid
    end
  end

  context "ezPay 電子發票載具" do
    it "有效的格式" do
      carrier = build(:carrier, :ezpay)
      expect(carrier).to be_valid
    end
  end
end
