# ExceptionFileNotifier

[![Gem Version](https://badge.fury.io/rb/exception_file_notifier.svg)](https://badge.fury.io/rb/exception_file_notifier)
[![Travis](https://api.travis-ci.org/fursich/exception_file_notifier.png)](http://travis-ci.org/fursich/exception_file_notifier)
[![MIT License](http://img.shields.io/badge/license-MIT-blue.svg?style=flat)](LICENSE)

**Exception File Notifier** is a custom notifier for [Exception Notification](https://github.com/smartinez87/exception_notification), that records notifications onto a log file when errors occur in a Rack/Rails application.

All the error logs are converted into JSON format. This would be useful typically when you wish to monitor an app with monitoring tools - e.g. Kibana + ElasticSearch + Fluentd, or anything alike.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'exception_file_notifier'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install exception_file_notifier

## Usage

Set proper configs in *config/initializers/exception_notification.rb*

To get started, use the simplest settings:

```ruby:config/initializers/exception_notification.rb
ExceptionNotification.configure do |config|

  config.add_notifier :file, {
      filename:  "#{Rails.root}/log/exceptions.log"
  }
```

That works in all the environment (including test).

You could also customize settings like so:

```ruby:config/initializers/exception_notification.rb
ExceptionNotification.configure do |config|

# disable all the notifiers in certain environment
  config.ignore_if do |exception, options|
    Rails.env.test?
  end

  config.add_notifier :file, {
      filename:  "#{Rails.root}/log/exceptions_#{Rails.env}.log",  # generate different log files depending on environments
      shift_age: 'daily'     # use shift_age/shift_size options to rotate log files
  }
```

You could also pass as many original values as you like, which will be evaluated JSON-ified at the time when an exception occurs. For detailed setting you may wish to consult with the Exception Notification [original readme](https://github.com/smartinez87/exception_notification).

#### available options:

- filename:   specify the log file (preferablly with its absolute path)

- shift_age:  option for log file rotation: directly passed to Ruby Logger

- shift_size: option for log file rotation: directly passed to Ruby Logger

(for the latter options see also: https://docs.ruby-lang.org/ja/latest/method/Logger/s/new.html)

#### Note

Due to [a bug](https://bugs.ruby-lang.org/issues/12948) with ruby Logger discovered in ruby 2.2 - 2.3, it might happen that you cannot rotate logs by using shift_age. (for those who come up with any workaround for this, please let us know / PR are welcomed)

Meanwhile you could cope with either 1) upgrading your ruby version upto 2.4, or 2) rotate logs by size, not date

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/fursich/exception_file_notifier.

## Special Thanks To

All the folks who have given supports, especially @motchang and @katsurak for great advises and reviews.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
