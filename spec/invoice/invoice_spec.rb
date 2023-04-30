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
      it "應稅商品，個人發票（B2C），不使用載具，即時開立發票" do
        taxable_item = build(:order_item)
        order = build(:order, item: taxable_item)

        invoice = Ezpay::PersonalInvoice.new(buyer:, order:, issue_method: :now)
        post_data = invoice.post_data

        expect(post_data[:Category]).to eq "B2C"
        expect(post_data[:BuyerName]).to eq buyer.name
        expect(post_data[:BuyerEmail]).to eq buyer.email
        expect(post_data[:Status]).to eq "1" # 即時開立發票
        expect(post_data[:CreateStatusTime]).to be nil
        expect(post_data[:PrintFlag]).to eq "Y" # 沒用任何載具或捐贈，印出紙本
        expect(post_data[:TaxType]).to eq "1" # 應稅
        expect(post_data[:TaxRate]).to eq ENV["DEFAULT_TAX_RATE"].to_i
        expect(post_data[:Amt]).to be order.total_amount(with_tax: false)
        expect(post_data[:ItemName]).to eq taxable_item.name
        expect(post_data[:ItemCount]).to eq taxable_item.quantity.to_s
        expect(post_data[:ItemUnit]).to eq taxable_item.unit
        expect(post_data[:TaxAmt]).to eq taxable_item.total_tax

        # 單價需含稅
        expect(post_data[:ItemPrice]).to eq taxable_item.price(
             with_tax: true
           ).to_s

        expect(post_data[:TotalAmt]).to eq taxable_item.total_amount(
             with_tax: true
           )

        # 數量 x 單價（含稅金額）
        expect(post_data[:ItemAmt]).to eq taxable_item.total_amount(
             with_tax: true
           ).to_s
      end

      it "應稅商品，個人發票，使用愛心捐贈碼，預約開立發票，要印發票" do
        taxable_item = build(:order_item)
        order = build(:order, item: taxable_item)
        carrier = build(:donation_carrier)

        issued_at = Date.today + 8

        invoice =
          Ezpay::PersonalInvoice.new(
            buyer:,
            order:,
            carrier:,
            issue_method: :scheduled,
            issued_at:,
            print_flag: true
          )
        post_data = invoice.post_data

        expect(post_data[:Category]).to eq "B2C"
        expect(post_data[:BuyerName]).to eq buyer.name
        expect(post_data[:BuyerEmail]).to eq buyer.email
        expect(post_data[:Status]).to eq "3" # 預約開立發票
        expect(post_data[:CreateStatusTime]).to eq issued_at.strftime(
             "%Y-%m-%d"
           ) # 預約開立發票

        expect(post_data[:PrintFlag]).to eq "Y" # 印出紙本
        expect(post_data[:TaxType]).to eq "1" # 應稅
        expect(post_data[:TaxRate]).to eq ENV["DEFAULT_TAX_RATE"].to_i
        expect(post_data[:Amt]).to be order.total_amount(with_tax: false)
        expect(post_data[:ItemName]).to eq taxable_item.name
        expect(post_data[:ItemCount]).to eq taxable_item.quantity.to_s
        expect(post_data[:ItemUnit]).to eq taxable_item.unit
        expect(post_data[:TaxAmt]).to eq taxable_item.total_tax

        # 單價需含稅
        expect(post_data[:ItemPrice]).to eq taxable_item.price(
             with_tax: true
           ).to_s

        expect(post_data[:TotalAmt]).to eq taxable_item.total_amount(
             with_tax: true
           )

        # 數量 x 單價（含稅金額）
        expect(post_data[:ItemAmt]).to eq taxable_item.total_amount(
             with_tax: true
           ).to_s
      end

      it "免稅商品，並且使用手機條碼載具，等待觸發開立發票（預設），不印紙本" do
        tax_exemption_item = build(:order_item, :tax_exemption)
        order = build(:order, item: tax_exemption_item)
        carrier = build(:barcode_carrier)

        invoice = Ezpay::PersonalInvoice.new(buyer:, order:, carrier:)
        post_data = invoice.post_data

        expect(post_data[:Category]).to eq "B2C"
        expect(post_data[:BuyerName]).to eq buyer.name
        expect(post_data[:BuyerEmail]).to eq buyer.email
        expect(post_data[:Status]).to eq "0" # 等待觸發開立發票
        expect(post_data[:CreateStatusTime]).to be nil
        expect(post_data[:PrintFlag]).to eq "N" # 印出紙本
        expect(post_data[:TaxType]).to eq "3" # 應稅
        expect(post_data[:TaxRate]).to eq 0
        expect(post_data[:Amt]).to be order.total_amount
        expect(post_data[:ItemName]).to eq tax_exemption_item.name
        expect(post_data[:ItemCount]).to eq tax_exemption_item.quantity.to_s
        expect(post_data[:ItemUnit]).to eq tax_exemption_item.unit
        expect(post_data[:TaxAmt]).to eq tax_exemption_item.total_tax
        expect(post_data[:ItemPrice]).to eq tax_exemption_item.price.to_s
        expect(post_data[:TotalAmt]).to eq tax_exemption_item.total_amount
        expect(post_data[:ItemAmt]).to eq tax_exemption_item.total_amount.to_s
      end

      it "零稅率商品，並使用自然人憑證載具，不印紙本，立即開立發票" do
        tax_zero_item = build(:order_item, :tax_zero)
        order = build(:order, item: tax_zero_item)
        carrier = build(:certificate_carrier)

        invoice =
          Ezpay::PersonalInvoice.new(
            buyer:,
            order:,
            carrier:,
            issue_method: :now,
            print_flag: false
          )
        post_data = invoice.post_data

        expect(post_data[:Category]).to eq "B2C"
        expect(post_data[:BuyerName]).to eq buyer.name
        expect(post_data[:BuyerEmail]).to eq buyer.email
        expect(post_data[:Status]).to eq "1" # 預約開立發票
        expect(post_data[:CreateStatusTime]).to be nil
        expect(post_data[:PrintFlag]).to eq "N" # 不印紙本
        expect(post_data[:TaxType]).to eq "2" # 應稅
        expect(post_data[:TaxRate]).to eq 0
        expect(post_data[:Amt]).to be order.total_amount
        expect(post_data[:ItemName]).to eq tax_zero_item.name
        expect(post_data[:ItemCount]).to eq tax_zero_item.quantity.to_s
        expect(post_data[:ItemUnit]).to eq tax_zero_item.unit
        expect(post_data[:TaxAmt]).to eq tax_zero_item.total_tax
        expect(post_data[:ItemPrice]).to eq tax_zero_item.price.to_s
        expect(post_data[:TotalAmt]).to eq tax_zero_item.total_amount
        expect(post_data[:ItemAmt]).to eq tax_zero_item.total_amount.to_s
      end
    end

    context "購買多項商品" do
      it "相同稅別（都是免稅），個人發票，使用愛心捐類碼，不印發票，預約開立發票" do
        tax_exemption_items = build_list(:order_item, 3, :tax_exemption)
        order = build(:order, item: tax_exemption_items)
        carrier = build(:donation_carrier)

        issued_at = Date.today + 4
        invoice =
          Ezpay::PersonalInvoice.new(
            buyer:,
            order:,
            carrier:,
            print_flag: false,
            issue_method: :scheduled,
            issued_at:
          )
        post_data = invoice.post_data

        expect(post_data[:Category]).to eq "B2C"
        expect(post_data[:BuyerName]).to eq buyer.name
        expect(post_data[:BuyerEmail]).to eq buyer.email
        expect(post_data[:Status]).to eq "3" # 預約開立發票
        expect(post_data[:CreateStatusTime]).to eq issued_at.strftime(
             "%Y-%m-%d"
           ) # 預約開立發票

        expect(post_data[:PrintFlag]).to eq "N" # 不印紙本
        expect(post_data[:TaxType]).to eq "3" # 免稅
        expect(post_data[:TaxRate]).to eq 0
        expect(post_data[:Amt]).to be order.total_amount
        expect(post_data[:ItemName]).to eq tax_exemption_items.map(&:name).join(
             "|"
           )
        expect(post_data[:ItemCount]).to eq tax_exemption_items.map(
             &:quantity
           ).join("|")
        expect(post_data[:ItemUnit]).to eq tax_exemption_items.map(&:unit).join(
             "|"
           )

        expect(post_data[:TaxAmt]).to eq 0 # 全部都是免稅

        expect(post_data[:TotalAmt]).to eq tax_exemption_items.sum(
             &:total_amount
           )

        # 單價
        expect(post_data[:ItemPrice]).to eq tax_exemption_items
             .map { |item| item.price }
             .join("|")

        # # 數量 x 單價（含稅金額）
        expect(post_data[:ItemAmt]).to eq tax_exemption_items
             .map { |item| item.total_amount(with_tax: true) }
             .join("|")
      end

      it "混合稅別，個人發票，使用自然人憑證載具，不印發票，立即開立發票" do
        taxable_items = build_list(:order_item, 3)
        tax_exemption_items = build_list(:order_item, 2, :tax_exemption)
        items = taxable_items + tax_exemption_items
        order = build(:order, item: items)

        carrier = build(:certificate_carrier)

        invoice =
          Ezpay::PersonalInvoice.new(
            buyer:,
            order:,
            carrier:,
            print_flag: false,
            issue_method: :now
          )
        post_data = invoice.post_data

        expect(post_data[:Category]).to eq "B2C"
        expect(post_data[:BuyerName]).to eq buyer.name
        expect(post_data[:BuyerEmail]).to eq buyer.email
        expect(post_data[:Status]).to eq "1" # 立即開立發票
        expect(post_data[:CreateStatusTime]).to be nil
        expect(post_data[:PrintFlag]).to eq "N" # 不印紙本
        expect(post_data[:TaxType]).to eq "9" # 混合稅別
        expect(post_data[:TaxRate]).to be ENV["DEFAULT_TAX_RATE"].to_i # 這個欄位不合理！

        expect(post_data[:Amt]).to be (
             taxable_items.sum { |item| item.total_amount(with_tax: false) } +
               tax_exemption_items.sum(&:total_amount)
           )
        expect(post_data[:ItemName]).to eq items.map(&:name).join("|")
        expect(post_data[:ItemCount]).to eq items.map(&:quantity).join("|")
        expect(post_data[:ItemUnit]).to eq items.map(&:unit).join("|")
        expect(post_data[:TaxAmt]).to eq taxable_items.sum(&:total_tax)
        expect(post_data[:TotalAmt]).to eq items.sum(&:total_amount)

        # 單價
        expect(post_data[:ItemPrice]).to eq items
             .map { |item| item.price(with_tax: true) }
             .join("|")

        # 數量 x 單價（含稅金額）
        expect(post_data[:ItemAmt]).to eq items
             .map { |item| item.total_amount }
             .join("|")
      end

      # 只有個人發票才會有混合稅別選項
      it "混合稅別，開公司發票會發生錯誤" do
        buyer = build(:company_buyer)
        taxable_items = build_list(:order_item, 3)
        tax_exemption_items = build_list(:order_item, 2, :tax_exemption)
        order = build(:order, item: taxable_items + tax_exemption_items)

        expect {
          Ezpay::CompanyInvoice.new(buyer:, order:)
        }.to raise_error Ezpay::Invoice::Error::MixedTaxError
      end

      it "相同稅別（應稅），開公司發票，預約開立發票" do
        buyer = build(:company_buyer)
        taxable_items = build_list(:order_item, 3)
        order = build(:order, item: taxable_items)
        issued_at = Date.today + 7

        invoice =
          Ezpay::CompanyInvoice.new(
            buyer:,
            order:,
            issue_method: :scheduled,
            issued_at:
          )

        post_data = invoice.post_data

        expect(post_data[:Category]).to eq "B2B"
        expect(post_data[:BuyerName]).to eq buyer.name
        expect(post_data[:BuyerEmail]).to eq buyer.email
        expect(post_data[:Status]).to eq "3" # 預約開立發票
        expect(post_data[:CreateStatusTime]).to eq issued_at.strftime(
             "%Y-%m-%d"
           ) # 預約開立發票

        expect(post_data[:PrintFlag]).to eq "Y" # 公司發票必印紙本
        expect(post_data[:TaxType]).to eq "1" # 混合稅別
        expect(post_data[:TaxRate]).to eq ENV["DEFAULT_TAX_RATE"].to_i

        expect(post_data[:Amt]).to be order.total_amount(with_tax: false)
        expect(post_data[:ItemName]).to eq taxable_items.map(&:name).join("|")
        expect(post_data[:ItemCount]).to eq taxable_items.map(&:quantity).join(
             "|"
           )
        expect(post_data[:ItemUnit]).to eq taxable_items.map(&:unit).join("|")
        expect(post_data[:TaxAmt]).to eq taxable_items.sum(&:total_tax)
        expect(post_data[:TotalAmt]).to eq taxable_items.sum(&:total_amount)

        # 單價
        expect(post_data[:ItemPrice]).to eq taxable_items.map(&:price).join("|")

        # 數量 x 單價（B2B 時要算未稅金額）
        expect(post_data[:ItemAmt]).to eq taxable_items
             .map { |item| item.total_amount(with_tax: false) }
             .join("|")
      end
    end
  end
end
