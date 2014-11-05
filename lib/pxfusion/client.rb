module Pxfusion
  class Client
    def initialize(username: nil, password: nil, return_url:, end_point: 'https://sec.paymentexpress.com/pxf/pxf.svc', opts: {}, debug: false)
      @username   = username || ENV['PXFUSION_USERNAME']
      @password   = password || ENV['PXFUSION_PASSWORD']
      raise 'WHY U NO SET USERNAME AND PASSWORD?' unless @username && @password
      @return_url = return_url
      opts.merge! pretty_print_xml: true, log: true if debug
      opts.merge! wsdl: end_point + '?wsdl', filters: [:password] #doesnt actually filter password because we build our own xml
      @client     = Savon::client(opts)
    end


    def get_session_id(amount:, txn_ref:, currency: 'NZD', txn_type: 'Purchase', return_url: nil, url_fillers:[], url_query:{})
      return_url = gen_return_url(base_url: return_url, fillers: url_fillers, query: url_query)
      answer = @client.call(:get_transaction_id, xml: gen_get_txn_id_xml(amount, currency, txn_type, return_url))
      begin
        result = answer.body[:get_transaction_id_response][:get_transaction_id_result]
      rescue
        raise answer.to_s
      end
      raise answer.to_s unless result[:success]
      result[:session_id]
    end


    def get_transaction session_id
      xml = gen_wrapper_xml 'GetTransaction', "<transactionId>#{session_id}</transactionId>"
      answer = @client.call(:get_transaction, xml: xml)
      result = answer.body[:get_transaction_response][:get_transaction_result]
      result[:status_description] = status_description result[:status]
      result
    end


    def cancel_transaction session_id
      xml = gen_wrapper_xml 'CancelTransaction', "<transactionId>#{session_id}</transactionId>"
      answer = @client.call(:cancel_transaction, xml: xml)
      answer.body[:cancel_transaction_response][:cancel_transaction_result]
    end


    def status_description status
      case status
      when '0' then 'Transaction approved'
      when '1' then 'Transaction declined'
      when '2' then 'Transaction declined due to transient error (retry advised)'
      when '3' then 'Invalid data submitted in form post (alert site admin)'
      when '4' then 'Transaction result cannot be determined at this time (re-run GetTransaction)'
      when '5' then 'Transaction did not proceed due to being attempted after timeout timestamp or having been cancelled by a CancelTransaction call'
      when '6' then 'No transaction found (SessionId query failed to return a transaction record – transaction not yet attempted)'
      end
    end


    private

    def gen_return_url(base_url: nil, fillers:[], query:{})
      url = (base_url || @return_url) % fillers
      url << "?#{URI.encode_www_form query}" unless query.empty?
      url
    end


    def gen_get_txn_id_xml amount, currency, txn_type, return_url
      content = <<-XML
        <tranDetail>
          <amount>#{'%.2f' % amount}</amount>
          <currency>#{currency}</currency>
          <returnUrl>#{return_url}</returnUrl>
          <txnType>#{txn_type}</txnType>
        </tranDetail>
      XML
      gen_wrapper_xml 'GetTransactionId', content
    end


    def gen_wrapper_xml action, content
      <<-XML
      <Envelope xmlns="http://schemas.xmlsoap.org/soap/envelope/">
        <Body>
          <#{action} xmlns="http://paymentexpress.com">
            <username>#{@username}</username>
            <password>#{@password}</password>
            #{content}
          </#{action}>
        </Body>
      </Envelope>
      XML
    end

  end
end
