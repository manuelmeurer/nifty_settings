module NiftySettings
  class Railtie < Rails::Railtie
    config.to_prepare do
      NiftySettings::Settings.reset!
    end
  end
end
