require 'pxfusion'

describe Pxfusion::Client do

  let(:client) do
    args = { username: 'Test', password: 'NuhUh', return_url: 'http://example.com/there'}
    Pxfusion::Client.new args
  end

  it "news up an instance" do
    expect(client).to be_a(Pxfusion::Client)
  end

  context 'get_transaction_id params' do
    it 'is satisfied with amount and txn_ref' do
      args = { amount: 1.23, txn_ref: 'Smucnh' }
      expect{client.get_transaction_id args}.to_not raise_exception
    end
  end
end
