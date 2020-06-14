require "active_record"

class DBConnector
  attr_reader :options
  attr_reader :rails_version
  attr_reader :type

  def initialize
    @options = {}

    raise "No BUNDLE_GEMFILE set" if ENV["BUNDLE_GEMFILE"].blank?

    @gemfile = File.basename(ENV["BUNDLE_GEMFILE"] || "", ".gemfile")

    _, @rails_version, @type = *@gemfile.match(/\Arails_(\d+)_(.+)\z/)

    case @type
    when /mysql2\z/
      options[:adapter]   = "mysql2"
      options[:username]  = ENV.fetch("MYSQL_USER", "root")
      options[:password]  = ENV.fetch("MYSQL_PASS", nil)
      options[:database]  = "wrapped_transaction_test"
      options[:encoding]  = "utf8"
    when /pg\z/
      options[:adapter]   = "postgresql"
      options[:database]  = "wrapped_transaction_test"
    when /sqlite3\z/
      options[:adapter]   = "sqlite3"
      options[:database]  = File.join(__dir__, "wrapped_transaction_test.sqlite3")
    else
      raise "Unknown db adapter: #{@type}"
    end
  end

  def ci?
    ENV["CI"].present?
  end
end

DBENV = DBConnector.new

ActiveRecord::Base.establish_connection DBENV.options

require_relative "./schema"
require_relative "./models"
