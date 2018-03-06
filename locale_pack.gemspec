require File.expand_path('../lib/locale_pack/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'locale_pack'
  s.version     = LocalePack::VERSION.dup
  s.date        = '2018-03-06'
  s.summary     = 'A tool for compiling and serving translations from Ruby backend applications to Javascript frontend components.'
  s.authors     = ['Christian Orthmann']
  s.email       = 'christian.orthmann@gmail.com'
  s.require_path = 'lib'
  s.files       = `git ls-files`.split("\n") - %w(.rvmrc .gitignore)
  s.test_files  = `git ls-files -- {test,spec,features}/*`.split("\n") - %w(.rvmrc .gitignore)
  s.homepage    = 'https://rubygems.org/gems/locale_pack'
  s.license     = 'MIT'

  s.add_development_dependency('rake', '~> 10')
  s.add_development_dependency('rspec', '~> 3')
  s.add_development_dependency('simplecov', '~> 0')
  s.add_development_dependency('simplecov-rcov', '~> 0')
  s.add_development_dependency('yard', '~> 0')
  s.add_development_dependency('factory_bot', '~> 4.0')
end
