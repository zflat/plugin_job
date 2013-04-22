# PluginJob

Framework for adding automation jobs as plugins to a host application.

## Installation

Add this line to your application's Gemfile:

    gem 'plugin_job'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install plugin_job

## Plugging jobs into an application

The client is responsible for maintaining a list of plugins available to it.

The host is responsible for maintaining a list of plugins it offers.

The application running the dispatcher is responsible for loading the plugins.

### Calling and loading plugins

The application running the dispatcher should load classes that implement the public methods of PluginJob::Worker.

The client requests a plugin to be run by sending the name of the worker class responsible for the job to the dispatcher.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
