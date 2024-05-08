require_relative "lib/webauthn/rails/version"

Gem::Specification.new do |spec|
  spec.name        = "webauthn-rails"
  spec.version     = Webauthn::Rails::VERSION
  spec.authors     = ["Matthew Rampey", "Sairo Guanipa"]
  spec.email       = ["matthew@softwaremaniacs.com", "sairojgg@gmail.com"]
  spec.homepage    = "http://mygemserver.com"
  spec.summary     = "Summary of Webauthn::Rails."
  spec.description = "Description of Webauthn::Rails."
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
end
