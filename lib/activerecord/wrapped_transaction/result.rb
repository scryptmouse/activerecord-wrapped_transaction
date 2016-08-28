module ActiveRecord
  module WrappedTransaction
    class Result
      TXN_COMPLETE  = Object.new.freeze
      NOT_CANCELLED = Object.new.freeze

      private_constant :TXN_COMPLETE
      private_constant :NOT_CANCELLED

      # @!attribute [r] cancellation_reason
      # @return [Object, nil]
      attr_reader :cancellation_reason

      # @!attribute [r] error
      # @return [Exception, nil]
      attr_reader :error

      # @!attribute [r] result
      # @return [Object, nil]
      attr_reader :result

      # @!attribute [r] transactor
      # @return [#transaction, ActiveRecord::ConnectionAdapters::AbstractAdapter]
      attr_reader :transactor

      # @param [#transaction, ActiveRecord::ConnectionAdapters::AbstractAdapter] transactor
      # @yield A block that goes in the transaction.
      # @yieldreturn [Object]
      def initialize(transactor: ActiveRecord::Base, transaction_options: {})
        unless block_given?
          raise ArgumentError, "Must call with a block to run in the transaction"
        end

        unless transactor.respond_to?(:transaction)
          raise ArgumentError, "transactor `#{transactor.inspect} must respond to :transaction"
        else
          @transactor = transactor
        end

        wrap_transaction transaction_options do
          execute_transaction do
            watch_for_cancellation do
              @result = yield
            end
          end
        end

        freeze
      end

      def cancelled?
        @cancelled
      end

      def success?
        @success
      end

      def rolled_back?
        !success?
      end

      private
      def wrap_transaction(transaction_options = {})
        caught = transactor.transaction(transaction_options) do
          yield
        end
      ensure
        @success = caught.eql?(TXN_COMPLETE)
      end

      def execute_transaction
        yield
      rescue Exception => e
        @error = e

        raise ActiveRecord::Rollback
      else
        TXN_COMPLETE
      end

      def watch_for_cancellation
        cancellation_reason = catch(:cancel_transaction) { yield; NOT_CANCELLED }

        unless cancellation_reason.eql?(NOT_CANCELLED)
          @cancelled = true
          @cancellation_reason = cancellation_reason
          raise ActiveRecord::Rollback, "Cancelled transaction"
        end
      end
    end
  end
end
