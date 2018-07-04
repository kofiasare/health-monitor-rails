# Monitoring

This is a rails monitoring mountable engine, which checks various services (db, cache, sidekiq, redis, etc.).

Mounting this gem will add a '/status' route to your application, which can be used for health monitoring the application and its various services. The method will return an appropriate HTTP status as well as an HTML/JSON/XML response representing the state of each provider.


## Setup

If you are using bundler add health-monitor-rails to your Gemfile:

```ruby
gem 'monitoring', git: 'https://github.com/kofiasare/monitoring.git'
```

Then run:

```bash
$ bundle install
```


## Usage
You can mount this inside your app routes by adding this to config/routes.rb:

```ruby
mount Monitoring::Engine, at: '/'
```

## Supported Service Providers
The following services are currently supported:
* DB
* Cache
* Redis
* Sidekiq
* Resque
* Delayed Job

## Configuration

### Adding Providers
By default, only the database check is enabled. You can add more service providers by explicitly enabling them via an initializer:

```ruby
Monitoring.configure do |config|
  config.cache
  config.redis
  config.sidekiq
  config.delayed_job
end
```

We believe that having the database check enabled by default is very important, but if you still want to disable it
(e.g., if you use a database that isn't covered by the check) - you can do that by calling the `no_database` method:

```ruby
Monitoring.configure do |config|
  config.no_database
end
```

### Provider Configuration

Some of the providers can also accept additional configuration:

```ruby
# Sidekiq
Monitoring.configure do |config|
  config.sidekiq.configure do |sidekiq_config|
    sidekiq_config.latency = 3.hours
    sidekiq_config.queue_size = 50
  end
end
```

```ruby
# Redis
Monitoring.configure do |config|
  config.redis.configure do |redis_config|
    redis_config.connection = Redis.current # use your custom redis connection
    redis_config.url = 'redis://user:pass@example.redis.com:90210/' # or URL
    redis_config.max_used_memory = 200 # Megabytes
  end
end
```

The currently supported settings are:

#### Sidekiq

* `latency`: the latency (in seconds) of a queue (now - when the oldest job was enqueued) which is considered unhealthy (the default is 30 seconds, but larger processing queue should have a larger latency value).
* `queue_size`: the size (maximim) of a queue which is considered unhealthy (the default is 100).

#### Redis

* `url`: the url used to connect to your Redis instance - note, this is an optional configuration and will use the default connection if not specified
* `connection`: Use custom redis connection (e.g., `Redis.current`).
* `max_used_memory`: Set maximum expected memory usage of Redis in megabytes. Prevent memory leaks and keys overstore.

#### Delayed Job

* `queue_size`: the size (maximim) of a queue which is considered unhealthy (the default is 100).

### Adding a Custom Provider
It's also possible to add custom health check providers suited for your needs (of course, it's highly appreciated and encouraged if you'd contribute useful providers to the project).

In order to add a custom provider, you'd need to:

* Implement the `monitoring::Providers::Base` class and its `check!` method (a check is considered as failed if it raises an exception):

```ruby
class CustomProvider < monitoring::Providers::Base
  def check!
    raise 'Oh oh!'
  end
end
```
* Add its class to the configuration:

```ruby
Monitoring.configure do |config|
  config.add_custom_provider(CustomProvider)
end
```

### Adding a Custom Error Callback
If you need to perform any additional error handling (for example, for additional error reporting), you can configure a custom error callback:

```ruby
Monitoring.configure do |config|
  config.error_callback = proc do |e|
    logger.error "Health check failed with: #{e.message}"

    Raven.capture_exception(e)
  end
end
```

### Adding Authentication Credentials
By default, the `/check` endpoint is not authenticated and is available to any user. You can authenticate using HTTP Basic Auth by providing authentication credentials:

```ruby
Monitoring.configure do |config|
  config.basic_auth_credentials = {
    username: 'SECRET_NAME',
    password: 'Shhhhh!!!'
  }
end
```

### Adding Environment Variables
By default, environment variables is `nil`, so if you'd want to include additional parameters in the results JSON, all you need is to provide a `Hash` with your custom environment variables:

```ruby
Monitoring.configure do |config|
  config.environment_variables = {
    build_number: 'BUILD_NUMBER',
    git_sha: 'GIT_SHA'
  }
end
```

### Customize
```ruby
Monitoring.configure do |config|
  config.customize = {
    title: 'My App Status Page',
    footer: '...'
  }
end
```

## License

The MIT License (MIT)

Copyright (c) 2017

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
