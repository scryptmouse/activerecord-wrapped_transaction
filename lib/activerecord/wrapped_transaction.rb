require "active_record"
require "activerecord/wrapped_transaction/version"
require "activerecord/wrapped_transaction/context"
require "activerecord/wrapped_transaction/result"

module ActiveRecord
  module WrappedTransaction
    extend ActiveSupport::Concern

    class InvalidTransactor < ArgumentError; end

    TRANSACTOR = ->(object) do
      object.tap do |o|
        raise InvalidTransactor, "#{object.inspect} must respond to #transaction" unless o.respond_to?(:transaction)
      end
    end

    included do
      delegate :wrapped_transaction, to: :class
    end

    class_methods do
      # @param [{ Symbol => Object }] options
      # @option options [Boolean] :requires_new
      # @option options [String] :isolation
      # @option options [Boolean] :joinable
      # @return [ActiveRecord::WrappedTransaction::Result]
      def wrapped_transaction(**options, &block)
        ActiveRecord::WrappedTransaction::Result.new(transactor: connection, **options, &block)
      end
    end

    class << self
      # @param [#transaction] transactor
      # @param [{ Symbol => Object }] options
      # @option options [Boolean] :requires_new
      # @option options [String] :isolation
      # @option options [Boolean] :joinable
      # @return [ActiveRecord::WrappedTransaction::Result]
      def call(transactor: ActiveRecord::Base, **options)
        ActiveRecord::WrappedTransaction::Result.new(transactor: transactor, **options) { yield }
      end
    end
  end
end
