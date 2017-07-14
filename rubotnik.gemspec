# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubotnik/version'

Gem::Specification.new do |spec|
  spec.name          = "rubotnik"
  spec.version       = Rubotnik::VERSION
  spec.authors       = ["Andy B"]
  spec.email         = ["andybarnov@gmail.com"]

  spec.summary       = %q{Write a short summary, because Rubygems requires one.} # TODO
  spec.description   = %q{Write a longer description or delete this line.} # TODO
  spec.homepage      = "http://localhost" # TODO
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

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

  spec.add_development_dependency "bundler", "~> 1.14"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
