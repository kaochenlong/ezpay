# frozen_string_literal: true

RSpec.describe Ezpay::Invoice::Buyer do
  context "個人" do
    it "個人發票" do
      buyer = build(:personal_buyer)
      expect(buyer).to be_personal
    end

    it "買受人名稱字數限制 30 字元" do
      expect {
        build(:personal_buyer, name: "longlong" * 10)
      }.to raise_error Ezpay::Invoice::Error::BuyerNameFormatError
    end
  end

  context "公司" do
    it "有效的公司發票" do
      buyer =
        Ezpay::Invoice::CompanyBuyer.new(
          name: "五倍紅寶石程式資訊教育股份有限公司",
          ubn: "83598406",
          email: "hi@5xcampus.com",
          address: "台北市衡陽路 7 號 5 樓"
        )

      expect(buyer).to be_company
      expect(buyer).to be_valid
    end

    it "買受人名稱字數限制 60 字元" do
      expect {
        build(:company_buyer, name: "longlonglong" * 10)
      }.to raise_error Ezpay::Invoice::Error::BuyerNameFormatError
    end

    it "如果沒填寫公司名稱，代入公司統編" do
      buyer = build(:company_buyer, name: nil)

      expect(buyer).to be_company
      expect(buyer).to be_valid
      expect(buyer.name).to eq buyer.ubn
    end

    it "不是有效的發票格式" do
      expect {
        Ezpay::Invoice::CompanyBuyer.new(ubn: "83598407")
      }.to raise_error(Ezpay::Invoice::Error::CompanyUBNFormatError)
    end
  end
end
