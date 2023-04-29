# frozen_string_literal: true

class Module
  def enum(name)
    const_get(name.to_s.upcase.to_sym)
  rescue NameError
    raise Ezpay::Invoice::Error::EnumMissingError
  end
end
