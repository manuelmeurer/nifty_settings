lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'nifty_settings/version'

Gem::Specification.new do |gem|
  gem.name          = 'nifty_settings'
  gem.version       = NiftySettings::VERSION
  gem.platform      = Gem::Platform::RUBY
  gem.authors       = ['Manuel Meurer']
  gem.email         = 'manuel.meurer@gmail.com'
  gem.summary       = 'Settings'
  gem.description   = 'Settings'
  gem.homepage      = ''
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r(^bin/)).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r(^(test|spec|features)/))
  gem.require_paths = ['lib']
end
