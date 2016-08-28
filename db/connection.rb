require 'active_record'

class DBConnector
  attr_reader :options

  def initialize
    @options = {}

    case ENV['DB']
    when /mysql/
      options[:adapter]   = 'mysql2'
      options[:username]  = 'root'
      options[:database]  = 'wrapped_transaction_test'
      options[:encoding]  = 'utf8'
    when /postgres/
      options[:adapter]   = 'postgresql'
      options[:database]  = 'wrapped_transaction_test'
    else
      options[:adapter]   = 'sqlite3'
      options[:database]  = File.join(__dir__, 'wrapped_transaction_test.sqlite3')
    end
  end

  def ci?
    ENV['CI'].present?
  end
end

ActiveRecord::Base.establish_connection DBConnector.new.options

require_relative './schema'
require_relative './models'
