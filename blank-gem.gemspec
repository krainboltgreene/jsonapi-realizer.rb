$:.push File.expand_path(File.join("..", "lib"), __FILE__)
require "blank-gem"

Gem::Specification.new do |spec|
  spec.name = "blank-gem"
  spec.version = Blankgem::VERSION
  spec.authors = ["Kurtis Rainbolt-Greene"]
  spec.email = ["kurtis@rainbolt-greene.online"]
  spec.summary = %q{x: Write a gem summary}
  spec.description = spec.summary
  spec.homepage = "http://krainboltgreene.github.io/blank-gem"
  spec.license = "ISC"

  spec.files = Dir[File.join("lib", "**", "*"), "LICENSE", "README.md", "Rakefile"]
  spec.executables = Dir[File.join("bin", "**", "*")].map { |f| f.gsub(/bin\//, "") }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "1.15.4"
  spec.add_development_dependency "rspec", "3.7.0"
  spec.add_development_dependency "rake", "12.2.1"
  spec.add_development_dependency "pry", "0.11.2"
  spec.add_development_dependency "pry-doc", "0.11.1"
end
