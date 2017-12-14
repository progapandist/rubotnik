# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubotnik/version'

Gem::Specification.new do |spec|
  spec.name          = "rubotnik"
  spec.version       = Rubotnik::VERSION
  spec.authors       = ["Andy Barnov"]
  spec.email         = ["andy.barnov@gmail.com"]

  spec.summary       = %q{Ruby "bot-end" micro-framework for Facebook Messenger}
  spec.homepage      = "https://github.com/progapandist/rubotnik"
  spec.license       = "MIT"
  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'facebook-messenger'
  spec.add_dependency 'addressable'
  spec.add_dependency 'dotenv'
  spec.add_dependency 'httparty'
  spec.add_dependency 'puma'
  spec.add_dependency 'sinatra'
  spec.add_dependency 'thor'

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
