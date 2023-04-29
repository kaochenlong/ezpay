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

    context "開立發票方式" do
      it "等待觸發開立發票" do
        invoice = build(:personal_invoice, issue_method: :wait)

        expect(invoice.issue_method).to be Ezpay::Invoice::IssueMethod::WAIT
      end

      it "即時開立發票" do
        issued_at = Date.today + 3
        invoice = build(:personal_invoice, issue_method: :now, issued_at:)

        expect(invoice.issue_method).to be Ezpay::Invoice::IssueMethod::NOW
        expect(invoice.issued_at).to be_nil
      end

      it "預約自動開立發票，須指定預計開立日期" do
        # 沒填寫開立日期
        expect {
          build(:personal_invoice, issue_method: :scheduled)
        }.to raise_error Ezpay::Invoice::Error::IssueDateError

        # 指定在過去的日期
        expect {
          build(
            :personal_invoice,
            issue_method: :scheduled,
            issued_at: Date.today - 7
          )
        }.to raise_error Ezpay::Invoice::Error::IssueDateError

        # 指定 7 天後開發票
        issued_at = Date.today + 7
        invoice = build(:personal_invoice, issue_method: :scheduled, issued_at:)

        expect(
          invoice.issue_method
        ).to be Ezpay::Invoice::IssueMethod::SCHEDULED
        expect(invoice.issued_at).to eq issued_at.strftime("%Y-%m-%d")
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

  context "開立發票" do
    let(:buyer) { build(:personal_buyer) }

    context "只購買一項商品" do
      it "應稅商品" do
        taxable_item = build(:order_item)
        order = build(:order, item: taxable_item)

        invoice = Ezpay::PersonalInvoice.new(buyer:, order:)
        p invoice.post_data
      end

      it "免稅商品" do
        tax_exemption_item = build(:order_item, :tax_exemption)
        order = build(:order, item: tax_exemption_item)

        invoice = Ezpay::PersonalInvoice.new(buyer:, order:)
        p invoice.post_data
      end

      it "零稅率商品" do
        tax_zero_item = build(:order_item, :tax_zero)
        order = build(:order, item: tax_zero_item)

        invoice = Ezpay::PersonalInvoice.new(buyer:, order:)
        p invoice.post_data
      end
    end

    context "購買多項商品" do
      it "相同稅別（都是免稅）" do
        tax_exemption_items = build_list(:order_item, 2, :tax_exemption)
        order = build(:order, item: tax_exemption_items)

        invoice = Ezpay::PersonalInvoice.new(buyer:, order:)

        p invoice.post_data
      end

      it "混合稅別" do
        taxable_items = build_list(:order_item, 3)
        tax_exemption_items = build_list(:order_item, 2, :tax_exemption)
        order = build(:order, item: taxable_items + tax_exemption_items)

        invoice = Ezpay::PersonalInvoice.new(buyer:, order:)

        p invoice.post_data
      end
    end
  end
end
