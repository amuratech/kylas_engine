# KylasEngine
The engine which handles Login, Signup, API key support and OAuth with Kylas CRM

## Usage
Please refer installation steps.

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'kylas_engine', git: 'https://github.com/amuratech/kylas_engine.git'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install kylas_engine
```

In your config/application.rb,
```ruby
KylasEngine::Context.setup(
  client_id: 'Paste client id generated for Marketplace app here',
  client_secret: 'Paste client secret generated for Marketplace app here',
  redirect_uri: 'Enter redirect uri that you have used while creating marketplace app',
  kylas_host: 'Enter Kylas host here'
  app_id: 'Enter marketplace app id here'
)
```

In your config/routes.rb file, (You can mount engine at any of your favourite path), If you have not added autheticated root path in routes.rb file then the user will be routed to engine's root path.
```ruby
mount KylasEngine::Engine, at: '/kylas-engine'

authenticated :user do
  root 'enter URL here on which user will be redirected after logged in'
end
```

Copy migration from kylas engine to your app
```ruby
bin/rails kylas_engine:install:migrations
```
Then run migrations
```ruby
bin/rails db:migrate
```

In your environments file (Based on your requirements),
```ruby
config.action_mailer.default_url_options = { host: 'http://localhost:3000' }
```

In your terminal execute below command, (This is used for encryption)
```bash
$ bin/rails db:encryption:init
```

In your app/assets/config/manifest.js, this will be used for precompiling assets
```js
//= link kylas_engine_manifest.js
```

If you want to override any models or controllers then you can create such files in ```app/overrides```
```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    overrides = "#{Rails.root}/app/overrides"
    Rails.autoloaders.main.ignore(overrides)

    config.to_prepare do
      Dir.glob("#{overrides}/**/*_override.rb").each do |override|
        load override
      end
    end
  end
end
```

For e.g.
For opening kylas_engine's user model
```ruby
# YourApp/app/overrides/models/kylas_engine/user_override.rb
KylasEngine::User.class_eval do
  # Add code here
end
```

## Contributing
NA

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
