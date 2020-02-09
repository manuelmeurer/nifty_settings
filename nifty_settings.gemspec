lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'nifty_settings/version'

Gem::Specification.new do |gem|
  gem.name          = 'nifty_settings'
  gem.version       = NiftySettings::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.author        = 'Manuel Meurer'
  gem.email         = 'manuel@krautcomputing.com'
  gem.summary       = 'A nifty way to save and access application-wide settings.'
  gem.description   = 'A nifty way to save and access application-wide settings.'
  gem.homepage      = ''
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r(^bin/)).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r(^(test|spec|features)/))
  gem.require_paths = ['lib']

  gem.add_dependency 'gem_config', '~> 0.3'
  gem.add_development_dependency 'rake', '~> 10.4'
  gem.add_development_dependency 'rspec', '~> 3.2'
  gem.add_development_dependency 'guard-rspec', '~> 4.5'
end
