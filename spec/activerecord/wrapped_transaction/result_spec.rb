require 'spec_helper'

RSpec.describe ActiveRecord::WrappedTransaction::Result do
  context 'with a succesful transaction' do
    subject { described_class.new { Widget.create! name: 'Something' } }

    it { is_expected.to be_a_success }
    it { is_expected.not_to be_cancelled }
    it { is_expected.not_to be_rolled_back }

    it 'has no cancellation reason' do
      expect(subject.cancellation_reason).to be_nil
    end

    specify 'the result of the transaction is available' do
      expect(subject.result).to be_a_kind_of Widget
    end
  end

  context 'with a transaction that raises some kind of error' do
    subject { described_class.new { Widget.create! } }

    it { is_expected.not_to be_cancelled }
    it { is_expected.not_to be_a_success }
    it { is_expected.to be_rolled_back }

    it 'has no cancellation reason' do
      expect(subject.cancellation_reason).to be_nil
    end

    it 'has no result' do
      expect(subject.result).to be_nil
    end

    it 'exposes the error' do
      expect(subject.error).to be_a_kind_of ActiveRecord::RecordInvalid
    end
  end

  context 'with a transaction that can be arbitrarily cancelled' do
    let(:reason) { double('some reason to cancel') }

    subject { described_class.new { throw :cancel_transaction, reason } }

    it { is_expected.to be_cancelled }
    it { is_expected.not_to be_a_success }
    it { is_expected.to be_rolled_back }

    it 'has a rollback as its error' do
      expect(subject.error).to be_a_kind_of(ActiveRecord::Rollback)
    end

    specify 'the cancellation reason is available' do
      expect(subject.cancellation_reason).to be reason
    end
  end

  specify 'creating without a block fails' do
    expect { described_class.new }.to raise_error(ArgumentError, /must call with a block/i)
  end

  specify 'creating with an invalid transactor fails' do
    actor = double('invalid transactor')

    allow(actor).to receive(:respond_to?).with(:transaction).and_return(false)

    expect { |b| described_class.new(transactor: actor, &b) }.to raise_error(ArgumentError, /transactor/i).and never_yield_control

    expect(actor).to have_received(:respond_to?).with(:transaction).once
  end
end
