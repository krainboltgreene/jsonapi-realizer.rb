lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jsonapi/realizer/version"

Gem::Specification.new do |spec|
  spec.name = "jsonapi-realizer"
  spec.version = JSONAPI::Realizer::VERSION
  spec.authors = ["Kurtis Rainbolt-Greene"]
  spec.email = ["kurtis@rainbolt-greene.online"]
  spec.summary = %q{A way to take json:api requests and turn them into models}
  spec.description = spec.summary
  spec.homepage = "http://krainboltgreene.github.io/jsonapi-realizer"
  spec.license = "ISC"

  spec.files = Dir[File.join("lib", "**", "*"), "LICENSE", "README.md", "Rakefile"]
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rspec", "~> 3.7"
  spec.add_development_dependency "rake", "~> 12.2"
  spec.add_development_dependency "pry", "~> 0.11"
  spec.add_development_dependency "activemodel", "~> 5.1"
  spec.add_development_dependency "activerecord", "~> 5.1"
  spec.add_development_dependency "pry-doc", "~> 0.11"
  spec.add_runtime_dependency "activesupport", "~> 5.1"
end
