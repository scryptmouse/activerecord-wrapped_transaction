$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'bundler/setup'
require 'database_cleaner/active_record'
require 'pry'
require 'simplecov'

SimpleCov.start do
  enable_coverage :branch

  add_filter { |src| src.filename =~ %r,db/(connection|models|schema), }
  add_filter 'spec/activerecord'
end

require 'activerecord/wrapped_transaction'
require_relative '../db/connection'

RSpec::Matchers.define_negated_matcher :never_yield_control, :yield_control

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with :truncation
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end
