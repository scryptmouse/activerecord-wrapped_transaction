# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord/wrapped_transaction/version'

Gem::Specification.new do |spec|
  spec.name          = "activerecord-wrapped_transaction"
  spec.version       = ActiveRecord::WrappedTransaction::VERSION
  spec.authors       = ["Alexa Grey"]
  spec.email         = ["devel@mouse.vc"]

  spec.summary       = %q{Wrap transactions in a manner that detects if the transaction completed}
  spec.description   = %q{Wrap transactions in a manner that detects if the transaction completed}
  spec.homepage      = "https://github.com/scryptmouse/activerecord-wrapped_transaction"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "activerecord", ">= 5", "< 7"

  spec.add_development_dependency "appraisal", "~> 2.3.0"
  spec.add_development_dependency "simplecov", "~> 0.18.5"
  spec.add_development_dependency "database_cleaner-active_record", "~> 1.8.0"
  spec.add_development_dependency "rake", ">= 12.3.3"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "pry"
end
