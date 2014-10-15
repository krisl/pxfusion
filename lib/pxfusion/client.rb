module Pxfusion
  class Client
    def initialize(username: nil, password: nil, return_url: nil)
      @username   = username
      @password   = password
      @return_url = return_url
    end

    def get_transaction_id(amount:, txn_ref:, currency: 'NZD', txn_type: 'Purchase')
    end
  end
end
