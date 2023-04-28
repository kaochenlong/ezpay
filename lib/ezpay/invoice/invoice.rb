# frozen_string_literal: true

module Ezpay
  class Invoice
    attr_reader :print_flag, :buyer

    def initialize(buyer:, category:, print_flag:, carrier:, comment:)
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
    end
  end

  class PersonalInvoice < Invoice
    def initialize(buyer:, print_flag: false, carrier: nil, comment: nil)
      # 如果沒設定任何載具或捐贈，print_flag 設定為 true
      print_flag = true if carrier.nil?
      super(category: :personal, buyer:, print_flag:, carrier:, comment:)
    end
  end

  class CompanyInvoice < Invoice
    def initialize(buyer:, carrier: nil, comment: nil)
      super(category: :company, buyer:, print_flag: true, carrier:, comment:)
    end
  end
end

# CreateStatusTime：預計開立日期
# Status 設定 3 才需要提供
# 格式 YYYY-MM-DD

# CustomsClearance：報關標記
# 零稅率（TaxRate = 0）才須使用的欄位
# 1 非經海關出口
# 2 經海關出口

# 非必填參數：
# TransNum：ezPay 平台交易序號，若同時使用 ezPay 金流服務可填寫此欄位，方便對帳。

# MerchantOrderNo：訂單編號
# 由商店自己決定編碼方式
# 僅能使用英文字母、數字以及底線 _
# Regex： /[a-zA-Z0-9_]+/

# KioskPrintFlag：是否開放至合作超 商 Kiosk 列印
# 當 CarrierType 設定為 2 時，才適用此參數
# 若不開放至合作超商 Kiosk 列印，則此參數為空值
# 1 發票中獎後開放列印（目前為全家便利商店）
