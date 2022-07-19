# frozen_string_literal: true

require 'net/http'

module KylasEngine
  # For fetch access & refresh token from IAM service
  class ExchangeCode
    def initialize(authorization_code:)
      @authorization_code = authorization_code
    end

    def call
      return { success: false, error_message: I18n.t('kylas_auth.code_blank') } if @authorization_code.blank?

      url = URI("#{KylasEngine::KYLAS_AUTH_CONFIG[:kylas_host]}/oauth/token")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      request = Net::HTTP::Post.new(url)
      request['Authorization'] = "Basic #{encoded_credentials}"
      request['Content-Type'] = 'application/x-www-form-urlencoded'
      request.body = payload
      response = https.request(request)
      if response.code == '200'
        res = JSON.parse(response.body)
        {
          success: true,
          access_token: res['access_token'],
          refresh_token: res['refresh_token'],
          expires_in: res['expires_in'].to_i
        }
      else
        Rails.logger.error "#{self.class} - #{response.code}"
        Rails.logger.error response.body
        { success: false }
      end
    end

    private

    def payload
      redirect_uri = KylasEngine::KYLAS_AUTH_CONFIG[:redirect_uri]
      "grant_type=authorization_code&code=#{@authorization_code}&redirect_uri=#{redirect_uri}"
    end

    def encoded_credentials
      cred = "#{KylasEngine::KYLAS_AUTH_CONFIG[:client_id]}:#{KylasEngine::KYLAS_AUTH_CONFIG[:client_secret]}"
      Base64.encode64(cred).gsub("\n", '')
    end
  end
end
