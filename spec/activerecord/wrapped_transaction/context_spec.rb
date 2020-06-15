require 'spec_helper'

RSpec.describe ActiveRecord::WrappedTransaction::Context do
  describe "#depth" do
    fit "can compute an arbitrarily nested depth" do
      expect do
        @result = Widget.wrapped_transaction do |ctx|
          ctx.wrap do |ctx1|
            ctx1.wrap do |ctx2|
              ctx2.depth
            end
          end
        end
      end.not_to raise_error

      expect(@result.result).to eq 2
    end
  end

  describe "#cancel!" do
    let(:reason) { "arbitrary" }

    it "allows us to cancel a transaction with an arbitrary reason" do
      expect do
        @result = Widget.wrapped_transaction do |ctx|
          ctx.cancel! reason
        end
      end.not_to raise_error

      expect(@result).to be_cancelled
      expect(@result.cancellation_reason).to eq reason
    end
  end
end
