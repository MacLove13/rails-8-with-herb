require_relative "lib/topsecret/version"

Gem::Specification.new do |spec|
  spec.name    = "topsecret"
  spec.version = Topsecret::VERSION
  spec.authors = [ "Rails 8 with Herb" ]
  spec.summary = "Protect sensitive model attributes with encryption."

  spec.files = Dir["lib/**/*.rb"]

  spec.add_dependency "activerecord", ">= 7.0"
  spec.add_dependency "activesupport", ">= 7.0"
end
