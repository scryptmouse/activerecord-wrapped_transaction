require "active_record"
require "activerecord/wrapped_transaction/version"
require "activerecord/wrapped_transaction/result"

module ActiveRecord
  module WrappedTransaction
    extend ActiveSupport::Concern

    included do
      delegate :wrapped_transaction, to: :class
    end

    class_methods do
      # @return [ActiveRecord::WrappedTransaction::Result]
      def wrapped_transaction(options = {}, &block)
        ActiveRecord::WrappedTransaction::Result.new(transactor: connection, transaction_options: options, &block)
      end
    end

    class << self
      def call(transactor: ActiveRecord::Base, **options)
        ActiveRecord::WrappedTransaction::Result.new(transactor: transactor, transaction_options: options) { yield }
      end
    end
  end
end
