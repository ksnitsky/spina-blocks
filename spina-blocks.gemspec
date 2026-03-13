# frozen_string_literal: true

$LOAD_PATH.push(File.expand_path("lib", __dir__))

require "spina/blocks/version"

Gem::Specification.new do |gem|
  gem.name = "spina-blocks"
  gem.version = Spina::Blocks::VERSION

  gem.authors = ["Konstantin Kanashchuk"]
  gem.email = ["ksnitsky@gmail.com"]
  gem.homepage = "https://github.com/ksnitsky/spina-blocks"
  gem.summary = "Block component library for Spina CMS"
  gem.description = "A plugin for Spina CMS that adds reusable block components that can be assembled into pages."
  gem.license = "MIT"

  gem.required_ruby_version = ">= 3.2.0"

  gem.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile", "README.md"]

  gem.add_dependency("spina", ">= 2.0")

  gem.add_development_dependency("database_cleaner-active_record")
  gem.add_development_dependency("factory_bot_rails")
  gem.add_development_dependency("pg")
  gem.add_development_dependency("rspec-rails")

  gem.metadata["rubygems_mfa_required"] = "true"
end
