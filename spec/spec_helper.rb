$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'bundler/setup'
require 'pry'
require 'simplecov'

SimpleCov.start do
  add_filter { |src| src.filename =~ %r,db/(connection|models|schema), }
  add_filter 'spec/activerecord'
end

require 'activerecord/wrapped_transaction'
require_relative '../db/connection'

RSpec::Matchers.define_negated_matcher :never_yield_control, :yield_control

RSpec.configure do |c|
  #c.verbose = false
end
