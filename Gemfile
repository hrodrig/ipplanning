source "https://rubygems.org"

# IPPLANNING: Ip Address Management System
# Modernized to Rails 8

gem "rails", "~> 8.0.0"

# Use mysql2 as the database for Active Record
gem "mysql2", "~> 0.5"

# Use Puma as the app server
gem "puma", ">= 5.0"

# Use Propshaft to serve assets
gem "propshaft"

# Use Importmap to manage JavaScript dependencies without Node.js
gem "importmap-rails"

# Use Hotwire (Turbo + Stimulus) for the frontend
gem "turbo-rails"
gem "stimulus-rails"

# Use Tailwind CSS for styling
gem "tailwindcss-rails"

# Build JSON APIs with ease
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", ">= 4.0"

# Use ActiveModel has_secure_password
# gem "bcrypt", "~> 3.1.7"

# Project Specific Gems
gem "devise"
gem "ipaddress"
gem "time_difference"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ]
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem "web-console"
end

group :test do
  # Adds support for Capybara system testing and selenium driver
  gem "capybara"
  gem "selenium-webdriver"
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]
