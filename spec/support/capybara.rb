require 'capybara/rspec'
require 'capybara/rails'
require 'capybara-screenshot/rspec'

Capybara.app = monitoring::Engine

RSpec.configure do |config|
  config.include monitoring::Engine.routes.url_helpers
end
