# frozen_string_literal: true

# TODO
# CustomsClearance：報關標記
# 零稅率（TaxRate = 0）才須使用的欄位
# 1 非經海關出口
# 2 經海關出口

# 非必填參數：
# TransNum：ezPay 平台交易序號，若同時使用 ezPay 金流服務可填寫此欄位，方便對帳。

# KioskPrintFlag：是否開放至合作超 商 Kiosk 列印
# 當 CarrierType 設定為 2 時，才適用此參數
# 若不開放至合作超商 Kiosk 列印，則此參數為空值
# 1 發票中獎後開放列印（目前為全家便利商店）

require "forwardable"

module Ezpay
  class Invoice
    module IssueMethod
      WAIT = "0" # 等待觸發開立發票（預設）
      NOW = "1" # 即時開立發票
      SCHEDULED = "3" # 預約自動開立發票
    end

    extend Forwardable
    attr_reader :print_flag,
                :buyer,
                :order,
                :issue_method,
                :issued_at,
                :carrier,
                :comment

    def initialize(
      buyer:,
      category:,
      print_flag:,
      carrier:,
      comment:,
      order:,
      issue_method:,
      issued_at:
    )
      if not buyer.is_a?(Buyer)
        raise Ezpay::Invoice::Error::BuyerError, "買受人格式錯誤"
      end

      if carrier && !carrier.is_a?(Carrier)
        raise Ezpay::Invoice::Error::CarrierError, "發票載具格式錯誤"
      end

      if comment && comment.length > 200
        raise Ezpay::Invoice::Error::CommentFormatError, "備註字數上限 200 字"
      end

      @buyer = buyer
      @category = category
      @print_flag = print_flag
      @carrier = carrier
      @order = order
      @issue_method = IssueMethod.enum(issue_method)
      self.issued_at = issued_at
    end

    def issued_at=(date = nil)
      if issue_method == IssueMethod::SCHEDULED
        raise Ezpay::Invoice::Error::IssueDateError, "需指定發票開立日期" if date.nil?

        if date < Date.today
          raise Ezpay::Invoice::Error::IssueDateError, "指定發票開立日期有誤"
        end

        @issued_at = date.strftime("%Y-%m-%d")
      else
        @issued_at = nil
      end
    end

    def post_data
      # TODO: TransNum, KioskPrintFlag, CustomsClearance

      common = {
        RespondType: "JSON",
        Version: "1.5",
        TimeStamp: Time.now.to_i.to_s,
        MerchantOrderNo: order.serial,
        Status: issue_method,
        CreateStatusTime: issued_at,
        BuyerName: buyer.name,
        BuyerUBN: buyer.ubn,
        BuyerAddress: buyer.address,
        BuyerEmail: buyer.email,
        PrintFlag: print_flag ? "Y" : "N",
        Comment: comment
      }

      items = {
        Amt: order.total_amount(with_tax: false), # 發票銷售額（未稅）
        TaxAmt: order.total_tax,
        TotalAmt: order.total_amount,
        ItemName: order.item_names,
        ItemCount: order.item_counts,
        ItemUnit: order.item_units,
        TaxType: order.items.first.tax.type,
        TaxRate: order.items.first.tax.rate
      }

      # 多筆購買項目而且不同課稅別
      if order.items.count > 1 && !order.same_tax_type?
        items[:TaxType] = Ezpay::Invoice::Tax::TaxType::MIXED
        amounts = order.amounts
        items[:AmtSales] = amounts[:taxable]
        items[:AmtZero] = amounts[:tax_zero]
        items[:AmtFree] = amounts[:tax_exemption]
        items[:ItemTaxType] = order.item_tax_types
        items[:Amt] = amounts[:taxable] + amounts[:tax_zero] +
          amounts[:tax_exemption]
      end

      common.merge(items)
    end

    def_delegators :@order, :total_amount
  end

  class PersonalInvoice < Invoice
    def initialize(
      buyer:,
      print_flag: false,
      carrier: nil,
      comment: nil,
      order: nil,
      issue_method: :wait,
      issued_at: nil
    )
      # 如果沒設定任何載具或捐贈，print_flag 設定為 true
      print_flag = true if carrier.nil?
      super(
        category: :personal,
        buyer:,
        print_flag:,
        carrier:,
        comment:,
        order:,
        issue_method:,
        issued_at:
      )
    end

    def post_data
      data = {
        Category: "B2C",
        ItemPrice: order.item_prices(with_tax: true),
        ItemAmt: order.item_total_amounts(with_tax: true)
      }

      if carrier&.type == Ezpay::Invoice::Carrier::CarrierType::DONATION
        data[:LoveCode] = carrier.number
      else
        data[:CarrierType] = carrier&.type
      end

      super.merge(data).compact
    end
  end

  class CompanyInvoice < Invoice
    def initialize(
      buyer:,
      carrier: nil,
      comment: nil,
      order: nil,
      issue_method: :wait,
      issued_at: nil
    )
      # 只有個人發票才有混合稅別
      if order && !order.same_tax_type?
        raise Ezpay::Invoice::Error::MixedTaxError
      end

      super(
        category: :company,
        buyer:,
        print_flag: true,
        carrier:,
        comment:,
        order:,
        issue_method:,
        issued_at:
      )
    end

    def post_data
      data = {
        Category: "B2B",
        CarrierType: nil,
        LoveCode: nil,
        ItemPrice: order.item_prices(with_tax: false),
        ItemAmt: order.item_total_amounts(with_tax: false)
      }

      super.merge(data).compact
    end
  end
end
