require 'spec_helper'

describe ActiveRecord::WrappedTransaction do
  let(:result_klass) { ActiveRecord::WrappedTransaction::Result }

  it 'has a version number' do
    expect(ActiveRecord::WrappedTransaction::VERSION).not_to be nil
  end

  it 'is callable' do
    allow(result_klass).to receive(:new).and_yield

    expect { |b| described_class.call(&b) }.to yield_control

    expect(result_klass).to have_received(:new)
  end

  context 'activerecord integration' do
    shared_examples_for 'something that implements wrapped_transaction' do
      let(:expected_result) { double('expected result') }

      it { is_expected.to respond_to :wrapped_transaction }

      it 'wraps a provided block and returns the result' do
        result = subject.wrapped_transaction { expected_result }

        expect(result).to be_a_kind_of(ActiveRecord::WrappedTransaction::Result)
        expect(result.result).to be expected_result
      end

      it 'catches any errors' do
        expect do
          subject.wrapped_transaction { raise Exception, 'Kaboom!' }
        end.not_to raise_error
      end

      it 'supports cancelling the transaction' do
        expect do
          subject.wrapped_transaction { throw :cancel_transaction }
        end.not_to throw_symbol
      end
    end

    context 'at the class level' do
      subject { Widget }

      it_should_behave_like 'something that implements wrapped_transaction'
    end

    context 'at an instance level' do
      let(:widget) { Widget.create! name: 'test' }

      subject { Widget.create! name: 'test' }

      it_should_behave_like 'something that implements wrapped_transaction'
    end
  end
end
