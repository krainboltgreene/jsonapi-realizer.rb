#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative "lib/jsonapi/realizer/version"

Gem::Specification.new do |spec|
  spec.name = "jsonapi-realizer"
  spec.version = JSONAPI::Realizer::VERSION
  spec.authors = ["Kurtis Rainbolt-Greene"]
  spec.email = ["kurtis@rainbolt-greene.online"]
  spec.summary = "A way to take json:api requests and turn them into models"
  spec.description = spec.summary
  spec.homepage = "http://krainboltgreene.github.io/jsonapi-realizer.rb"
  spec.license = "HL3"
  spec.required_ruby_version = "~> 3.2"

  spec.files = Dir[File.join("lib", "**", "*"), "LICENSE", "README.md", "Rakefile"]
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "activesupport"
  spec.add_runtime_dependency "addressable"
  spec.add_runtime_dependency "kaminari"
  spec.metadata["rubygems_mfa_required"] = "true"
end
