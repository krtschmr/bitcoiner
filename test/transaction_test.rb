# frozen_string_literal: true

require 'test_helper'

class TransactionTest < Minitest::Test
  context 'a transaction' do
    setup do
      @client = stub
      @acc = Bitcoiner::Account.new @client, 'pi'
      @txn = Bitcoiner::Transaction.new @client, @acc, 'testtxnid'
    end

    context 'with a detail_hash' do
      setup do
        @client.expects(:request)
               .once
               .with('gettransaction', 'testtxnid')
               .returns('amount' => 3.14,
                        'confirmations' => 420,
                        'txid' => 'testtxnid',
                        'time' => 1_234_567_890,
                        'details' => {
                          'account' => 'pi',
                          'address' => 'testaddress',
                          'category' => 'receive',
                          'amount' => 3.14
                        })
      end

      should 'have an amount and time' do
        assert_equal 3.14, @txn.amount
        assert_equal Time.at(1_234_567_890), @txn.time
      end

      should 'have confirmations and be confirmed' do
        assert_equal 420, @txn.confirmations
        assert @txn.confirmed?
      end
    end

    context 'without a detail_hash' do
      setup do
        @client.expects(:request)
               .at_least_once
               .with('gettransaction', 'testtxnid')
               .raises(ArgumentError)
      end

      should 'have a sane inspect' do
        assert_equal '#<Bitcoiner::Transaction testtxnid UNCONFIRMED>', @txn.inspect
      end

      should 'have zero confirmations and be unconfirmed' do
        assert_equal 0, @txn.confirmations
        assert !@txn.confirmed?
      end
    end
  end
end
