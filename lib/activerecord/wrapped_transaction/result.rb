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

      # @param [#transaction, ActiveRecord::ConnectionAdapters::AbstractAdapter] transactor
      # @param [ActiveRecord::WrappedTransaction::Context] parent_context
      # @param [{ Symbol => Object }] options
      # @option options [Boolean] :requires_new
      # @option options [String] :isolation
      # @option options [Boolean] :joinable
      # @yield A block that goes in the transaction.
      # @yieldreturn [Object]
      def initialize(transactor: ActiveRecord::Base, parent_context: nil, **options)
        raise ArgumentError, "Must call with a block to run in the transaction" unless block_given?

        @context = Context.new transactor: transactor, parent: parent_context, **options

        wrap_transaction do
          execute_transaction do
            watch_for_cancellation do
              @result = unwrap yield @context
            end
          end
        end

        freeze
      end

      def cancelled?
        @cancelled
      end

      # @!attribute [r] result
      # @return [Object, nil]
      def result
        @result if success?
      end

      def rolled_back?
        !success?
      end

      def success?
        @success
      end

      private

      def wrap_transaction
        caught = @context.wrap_transaction do
          yield
        end
      ensure
        @success = caught.eql? TXN_COMPLETE
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

        return if cancellation_reason.eql? NOT_CANCELLED

        @cancelled = true
        @cancellation_reason = cancellation_reason

        raise ActiveRecord::Rollback, "Cancelled transaction"
      end

      def unwrap(value)
        return value unless value.kind_of?(self.class) && value.success?

        value.result
      end
    end
  end
end
