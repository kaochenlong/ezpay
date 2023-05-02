# frozen_string_literal: true

require "openssl"

module Ezpay
  module Encryptor
    module AES_256_CBC
      def self.encrypt(text:, key:, iv:)
        cipher = OpenSSL::Cipher.new("AES-256-CBC")
        cipher.encrypt
        cipher.key = key
        cipher.iv = iv

        encrypted_message = cipher.update(text) + cipher.final
        encrypted_message.unpack("H*").first
      end

      def self.decrypt(text:, key:, iv:)
        cipher = OpenSSL::Cipher.new("AES-256-CBC")
        cipher.decrypt
        cipher.key = key
        cipher.iv = iv

        cipher.update([text].pack("H*")) + cipher.final
      end
    end
  end
end
