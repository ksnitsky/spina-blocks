$:.push File.expand_path('lib', __dir__)

require 'spina/blocks/version'

Gem::Specification.new do |gem|
  gem.name = 'spina-blocks'
  gem.version = Spina::Blocks::VERSION

  gem.authors = ['Konstantin Kanashchuk']
  gem.email = ['ksnitsky@gmail.com']
  gem.homepage = 'https://github.com/ksnitsky/spina-blocks'
  gem.summary = 'Block component library for Spina CMS'
  gem.description = 'A plugin for Spina CMS that adds reusable block components that can be assembled into pages.'
  gem.license = 'MIT'

  gem.required_ruby_version = '>= 2.7.0'

  gem.files = Dir['{app,config,db,lib}/**/*'] + ['Rakefile', 'README.md']

  gem.add_dependency 'spina', '>= 2.0'
end
