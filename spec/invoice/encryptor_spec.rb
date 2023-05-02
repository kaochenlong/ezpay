# frozen_string_literal: true

require "ezpay/encryptor/aes_256_cbc"
require "securerandom"

RSpec.describe Ezpay::Encryptor do
  let(:key) { "sEesjGGvgOPyQAPHFTGZ3h2eVMHXqN0S" } # fake key, just for testing purpose
  let(:iv) { "LZg2ghVd5DJ5838c" } # fake iv, just for testing purpose}

  context "加密" do
    it "進行 AES-256-CBC 加密" do
      text = "thankyou9527"

      result = Ezpay::Encryptor::AES_256_CBC.encrypt(text:, key:, iv:)

      expect(result).to eq "fe2ed0468172ab347aced6e989d2bb12"
    end
  end

  context "解密" do
    it "進行 AES-256-CBC 解密" do
      text = "fe2ed0468172ab347aced6e989d2bb12"

      result = Ezpay::Encryptor::AES_256_CBC.decrypt(text:, key:, iv:)

      expect(result).to eq "thankyou9527"
    end
  end
end
