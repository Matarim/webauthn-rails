require_relative "lib/webauthn_rails/rails/n"

Gem::Specification.new do |spec|
  spec.name        = "webauthn-rails"
  spec.version     = WebauthnRails::VERSION
  spec.authors     = ["Matthew Rampey", "Sairo Guanipa"]
  spec.email       = ["matthew@poormansascent.com", "sairojgg@gmail.com"]
  spec.homepage    = "https://github.com/Matarim/webauthn-rails"
  spec.summary     = "Webauthn with Rails"
  spec.description = "Integrate Webauthn into your Rails application with ease."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "http://mygemserver.com"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "http://mygemserver.com"
  spec.metadata["changelog_uri"] = "http://mygemserver.com"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1.3"
  spec.add_dependency "webauthn", "~> 3.1"

  add_development_dependency "rspec-rails", "~> 3.1.0"
end
