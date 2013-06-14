module NiftySettings
end

require 'nifty-settings/version'
require 'nifty-settings/settings'
require 'nifty-settings/railtie' if defined?(Rails)

::Settings = NiftySettings::Settings unless defined?(::Settings)
