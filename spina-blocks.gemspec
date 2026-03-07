$:.push File.expand_path('lib', __dir__)

require 'spina/blocks/version'

Gem::Specification.new do |gem|
  gem.name = 'spina-blocks'
  gem.version = Spina::Blocks::VERSION

  gem.authors = ['Spina Blocks']
  gem.email = ['dev@example.com']
  gem.homepage = 'https://github.com/example/spina-blocks'
  gem.summary = 'Block component library for Spina CMS'
  gem.description = 'A plugin for Spina CMS that adds reusable block components that can be assembled into pages.'
  gem.license = 'MIT'

  gem.required_ruby_version = '>= 2.7.0'

  gem.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile', 'README.md']

  gem.add_dependency 'spina', '>= 2.0'
end
