module ActiveRecord
  module WrappedTransaction
    class Context
      # @!attribute [r] transactor
      # @return [#transaction, ActiveRecord::ConnectionAdapters::AbstractAdapter]
      attr_reader :transactor

      attr_reader :isolation
      attr_reader :requires_new
      attr_reader :joinable

      # @!attribute [r] parent
      # @return [ActiveRecord::WrappedTransaction::Context]
      attr_reader :parent

      def initialize(transactor:, requires_new: nil, isolation: nil, joinable: true, parent: nil)
        @transactor = TRANSACTOR[transactor]
        @requires_new = requires_new
        @isolation = isolation
        @joinable = joinable
        @parent = parent

        @transaction_options = {
          requires_new: @requires_new,
          isolation: @isolation,
          joinable: @joinable
        }.freeze
      end

      # @!attribute [r] depth
      # The depth of the wrapped transaction
      # @return [Integer]
      def depth
        @depth ||= calculate_depth
      end

      # @return [ActiveRecord::WrappedContext::Result]
      def maybe(**new_options, &block)
        new_options[:joinable] = false
        new_options[:requires_new] = true

        build_result(**new_options, &block)
      end

      # @return [ActiveRecord::WrappedContext::Result]
      def wrap(**new_options, &block)
        build_result(**new_options, &block)
      end

      # Cancel the current transaction with an arbitrary `reason`.
      #
      # @param [String] reason
      # @return [void]
      def cancel!(reason = nil)
        throw :cancel_transaction, reason
      end

      # @api private
      def wrap_transaction
        transactor.transaction **@transaction_options do
          yield
        end
      end

      private

      def build_result(**new_options, &block)
        options = build_result_options(**new_options)

        Result.new(**options, &block)
      end

      def build_result_options(requires_new: @requires_new, isolation: @isolation, joinable: @joinable, **unused_options)
        # :nocov:
        unused_options.each do |key, value|
          warn "received unused option: #{key.inspect} => #{value.inspect}"
        end
        # :nocov:

        {
          transactor: @transactor,
          requires_new: requires_new,
          isolation: isolation,
          joinable: joinable,
          parent_context: self
        }
      end

      # @return [Integer]
      def calculate_depth
        parent.nil? ? 0 : parent.depth + 1
      end
    end
  end
end
