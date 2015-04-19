require 'gem_config'

module NiftySettings
  include GemConfig::Base

  with_configuration do
    has :settings_file, classes: [String, Pathname]
    has :settings_dir, classes: [String, Pathname]
  end
end

require 'nifty_settings/version'
require 'nifty_settings/settings'
require 'nifty_settings/railtie' if defined?(Rails)

::Settings = NiftySettings::Settings unless defined?(::Settings)
