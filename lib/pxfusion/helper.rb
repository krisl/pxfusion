module Pxfusion
  module Helper
    def cardnumber_field_tag(name = 'CardNumber', value = nil, options = {})
      text_field_tag name, value, options.update(autocomplete: 'cc-number')
    end

    def expirycombined_field_tag(name, value = nil, options = {})
      text_field_tag name, value, options.update(autocomplete: 'cc-exp')
      hidden_field_tag 'ExpiryMonth'
      hidden_field_tag 'ExpiryYear'
    end

    def expirymonth_field_tag(value = nil, options = {})
      text_field_tag ExpiryMonth, value, options.update(autocomplete: 'cc-exp-month')
    end

    def expiryyear_field_tag(value = nil, options = {})
      text_field_tag ExpiryYear, value, options.update(autocomplete: 'cc-exp-year')
    end

    def cardholdername_field_tag(value = nil, options = {})
      text_field_tag CardHolderName, value, options.update(autocomplete: 'cc-name')
    end

    def cvc_field_tag(options = {})
      text_field_tag 'Cvc2', nil, options.update(autocomplete: 'off')
    end

    def session_field_tag(value, options = {})
      hidden_field_tag 'SessionId', value, options
    end


  end
end
puts 'including action view helper'
ActionView::Base.send :include, Pxfusion::Helper
