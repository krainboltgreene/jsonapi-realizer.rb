$:.push File.expand_path(File.join("..", "lib"), __FILE__)
require "jsonapi-marshal"

Gem::Specification.new do |spec|
  spec.name = "jsonapi-marshal"
  spec.version = JSONAPI::Marshal::VERSION
  spec.authors = ["Kurtis Rainbolt-Greene"]
  spec.email = ["kurtis@rainbolt-greene.online"]
  spec.summary = %q{A way to take json:api requests and turn them into models}
  spec.description = spec.summary
  spec.homepage = "http://krainboltgreene.github.io/jsonapi-marshal"
  spec.license = "ISC"

  spec.files = Dir[File.join("lib", "**", "*"), "LICENSE", "README.md", "Rakefile"]
  spec.executables = Dir[File.join("bin", "**", "*")].map { |f| f.gsub(/bin\//, "") }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.15"
  spec.add_development_dependency "rspec", "~> 3.7"
  spec.add_development_dependency "rake", "~> 12.2"
  spec.add_development_dependency "pry", "~> 0.11"
  spec.add_development_dependency "activemodel", "~> 5.1"
  spec.add_development_dependency "pry-doc", "~> 0.11"
  spec.add_runtime_dependency "activesupport", "~> 5.1"
end
