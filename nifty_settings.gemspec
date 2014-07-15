lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'nifty_settings/version'

Gem::Specification.new do |gem|
  gem.name          = 'nifty_settings'
  gem.version       = NiftySettings::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.author        = 'Manuel Meurer'
  gem.email         = 'manuel@krautcomputing.com'
  gem.summary       = 'Settings'
  gem.description   = 'Settings'
  gem.homepage      = 'http://krautcomputing.github.io/nifty_settings'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r(^bin/)).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r(^(test|spec|features)/))
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 2.14.0'
  gem.add_development_dependency 'rb-fsevent', '~> 0.9.0'
  if RUBY_VERSION < '1.9.3'
    # Use older Guard version that uses older Listen version since
    # Listen >= 2.0.0 only works with Ruby >= 1.9.3
    gem.add_development_dependency 'guard-rspec', '~> 3.1.0'
    gem.add_development_dependency 'listen', '< 2.0.0' if RUBY_VERSION < '1.9.3'
  else
    gem.add_development_dependency 'guard-rspec', '~> 4.2.0'
  end
end
