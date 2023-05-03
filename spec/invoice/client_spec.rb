# frozen_string_literal: true

RSpec.describe Ezpay::Invoice::Client do
  context "建立 Client" do
    it "直接指定 Merchant ID & Hash Key & Hash IV" do
      client =
        Ezpay::Invoice::Client.new(
          merchant_id: "12345678",
          hash_key: "YOUR-HASH-KEY-9527",
          hash_iv: "YOUR-HASH-IV-C8763"
        )

      expect(client).to be_ready
    end

    it "如果沒指定，可從環境變數取得 Merchant ID & HashKey & Hash IV" do
      client = Ezpay::Invoice::Client.new

      expect(client).to be_ready
    end

    context "發票應該有可正常運作之 client" do
      it "手動指定 client 給 Invoice" do
        client = build(:client)
        invoice = build(:personal_invoice, client:)

        expect(invoice).to be_ready
      end

      it "不指定 client 會自動生成一個" do
        invoice = build(:company_invoice)

        expect(invoice).to be_ready
      end

      it "如果沒有訂單，無法開立發票" do
        invoice = build(:personal_invoice, order: nil)

        expect(invoice).not_to be_ready
      end
    end

    context "開立發票" do
      let(:client) do
        Ezpay::Invoice::Client.new(
          merchant_id: "34884285",
          hash_key: "wssZVYeLltlQgeagP0AghNtuvgytejqz",
          hash_iv: "CDibtBWdmwvXOJCP"
        )
      end

      context "個人發票（B2C）" do
        it "開立等待觸發開立發票（預設），不使用載具", :vcr do
          invoice = build(:personal_invoice, client:)

          result = invoice.issue!

          expect(result).to be_an(Ezpay::Invoice::Response)
          expect(result).to be_success
        end

        it "開立預約自動開立發票，使用自然人憑證載具", :vcr do
          carrier = build(:certificate_carrier)
          invoice =
            build(
              :personal_invoice,
              client:,
              carrier:,
              issue_method: :scheduled,
              issued_at: Date.today + 3
            )

          result = invoice.issue!

          expect(result).to be_an(Ezpay::Invoice::Response)
          expect(result).to be_success
        end

        it "立即開立發票，使用手機條碼載具", :vcr do
          invoice = build(:personal_invoice, client:)

          result = invoice.issue!

          expect(result).to be_an(Ezpay::Invoice::Response)
        end
      end

      context "公司發票（B2C）" do
        it "立即開立發票", :vcr do
          invoice = build(:company_invoice, client:, issue_method: :now)

          result = invoice.issue!

          expect(result).to be_an(Ezpay::Invoice::Response)
          p result
        end
      end
    end
  end
end
