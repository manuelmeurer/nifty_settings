module NiftySettings
end

require 'nifty_settings/version'
require 'nifty_settings/settings'
require 'nifty_settings/railtie' if defined?(Rails)

::Settings = NiftySettings::Settings unless defined?(::Settings)
