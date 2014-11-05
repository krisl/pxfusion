module Pxfusion

  TRANSACTION_APPROVED           = '0'
  TRANSACTION_DECLINED           = '1'
  TRANSACTION_DECLINED_TRANSIENT = '2'
  INVALID_DATA_SUBMITTED         = '3'
  TRANSACTION_RESULT_UNAVAILABLE = '4'
  TRANSACTION_CANCELLED          = '5'
  TRANSACTION_NOT_FOUND          = '6'

  class Client
    def initialize(username: nil, password: nil, return_url:, end_point: 'https://sec.paymentexpress.com/pxf/pxf.svc', opts: {}, debug: false)
      @username   = username || ENV['PXFUSION_USERNAME']
      @password   = password || ENV['PXFUSION_PASSWORD']
      raise 'WHY U NO SET USERNAME AND PASSWORD?' unless @username && @password
      @return_url = return_url
      opts.merge! pretty_print_xml: true, log: true if debug
      opts.merge! wsdl: end_point + '?wsdl', filters: [:password]
      opts.merge! env_namespace: '', namespace: '', namespace_identifier: nil
      @client     = Savon::client(opts)
    end


    def get_session_id(amount:, txn_ref:, currency: 'NZD', txn_type: 'Purchase', return_url: nil, url_fillers:[], url_query:{})
      return_url = gen_return_url(base_url: return_url, fillers: url_fillers, query: url_query)
      answer = request(:get_transaction_id, gen_get_txn_id_msg(amount, currency, txn_type, return_url))
      begin
        result = answer.body[:get_transaction_id_response][:get_transaction_id_result]
      rescue
        raise answer.to_s
      end
      raise answer.to_s unless result[:success]
      result[:session_id]
    end


    def get_transaction session_id
      answer = request(:get_transaction, transaction_id: session_id)
      result = answer.body[:get_transaction_response][:get_transaction_result]
      result[:status_description] = status_description result[:status]
      result
    end


    def cancel_transaction session_id
      answer = request(:cancel_transaction, transaction_id: session_id)
      answer.body[:cancel_transaction_response][:cancel_transaction_result]
    end


    def status_description status
      case status
      when TRANSACTION_APPROVED           then 'Transaction approved'
      when TRANSACTION_DECLINED           then 'Transaction declined'
      when TRANSACTION_DECLINED_TRANSIENT then 'Transaction declined due to transient error (retry advised)'
      when INVALID_DATA_SUBMITTED         then 'Invalid data submitted in form post (alert site admin)'
      when TRANSACTION_RESULT_UNAVAILABLE then 'Transaction result cannot be determined at this time (re-run GetTransaction)'
      when TRANSACTION_CANCELLED          then 'Transaction did not proceed due to being attempted after timeout timestamp or having been cancelled by a CancelTransaction call'
      when TRANSACTION_NOT_FOUND          then 'No transaction found (SessionId query failed to return a transaction record – transaction not yet attempted)'
      end
    end


    private

    def gen_return_url(base_url: nil, fillers:[], query:{})
      url = (base_url || @return_url) % fillers
      url << "?#{URI.encode_www_form query}" unless query.empty?
      url
    end

    def request name, details
      @client.call name, message: auth_wrap(details), attributes: {xmlns: 'http://paymentexpress.com'}
    end

    def gen_get_txn_id_msg amount, currency, txn_type, return_url
      {
        tran_detail: {
          amount:     '%.2f' % amount,
          currency:   currency,
          return_url: return_url,
          txn_type:   txn_type
        }
      }
    end


    def auth_wrap content
      {
        username: @username,
        password: @password
      }.merge content
    end

  end
end
