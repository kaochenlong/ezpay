# frozen_string_literal: true

require_relative "lib/ezpay/version"

Gem::Specification.new do |spec|
  spec.name = "ezpay"
  spec.version = Ezpay::VERSION
  spec.authors = ["Eddie"]
  spec.email = ["eddie@5xcampus.com"]

  spec.summary = "ezPay"
  spec.description = "Service and Helper for ezPay"
  spec.homepage = "https://github.com/kaochenlong/ezpay"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/kaochenlong/ezpay"
  spec.metadata["changelog_uri"] = "https://github.com/kaochenlong/ezpay/releases"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
end
