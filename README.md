Nifty Settings
==============

[![Gem Version](https://badge.fury.io/rb/nifty_settings.png)](http://badge.fury.io/rb/nifty_settings)
[![Build Status](https://secure.travis-ci.org/krautcomputing/nifty_settings.png)](http://travis-ci.org/krautcomputing/nifty_settings)
[![Dependency Status](https://gemnasium.com/krautcomputing/nifty_settings.png)](https://gemnasium.com/krautcomputing/nifty_settings)
[![Code Climate](https://codeclimate.com/github/krautcomputing/nifty_settings.png)](https://codeclimate.com/github/krautcomputing/nifty_settings)

An easy way to access settings across your application. Great for managing different configurations for different environments.

Installation
------------

Add this line to your application's Gemfile:

```ruby
gem 'nifty_settings'
```

Add your settings in YAML format under `config/settings.yml`


How to use it
-------------
Let's say we have the following settings file:

```
default:
  some_service:
    use_live?: false

development:
  foo: bar_dev
  wibble:
    wobble: wubble
  some_collection:
    - first
    - second

test:
  foo: bar_test

production:
  foo: bar
  some_service:
    use_live?: true
    key: my_secret_key
    timeout: 20
```
We can access the settings by using `Settings.key_name`. A combination of default values and environment specific settings can be used. NiftySettings will use the correct setting based on your current environment.

Let's use the above settings in a development environment:
```ruby
$> Settings.foo
$> => "bar_dev"
$> Settings.some_collection
$> => ["first", "second"]
````

Settings can be nested:
```ruby
$> Settings.wibble.wobble
$> => "wubble"
```

If a settings isn't defined for the current environment, it will fall back to the default value:
```ruby
$> Settings.some_service.use_live?
$> => false
```

And if the setting doesn't exist at all, it just returns `nil`:
```ruby
$> Settings.fizzbuzz
$> => nil
```

Using the same settings in a production environment, it picks up the environment specific settings:
```ruby
$> Settings.foo
$> => "bar"
$> Settings.some_service.use_live?
$> => true
$> Settings.some_service.timeout
$> => 20
```

Configuration Options
---------------------

### Specify configuration file

By default nifty_settings looks for settings in config/settings.yml, but this can be changed by setting the path in an initializer. 

```ruby
NiftySettings::Settings.settings_path = '/home/shared/other_settings.yml'
```

### Namespacing

Already have a `Settings` model? If so the settings can be accessed using `NiftySettings::Settings` instead.