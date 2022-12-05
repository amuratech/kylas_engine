# frozen_string_literal: true

require 'net/http'

module KylasEngine
  class TenantDetails
    def initialize(user:)
      @user = user
    end

    def call
      access_token = @user.fetch_access_token
      return { success: false } if access_token.nil?

      url = URI("#{KylasEngine::KYLAS_AUTH_CONFIG[:kylas_host]}/v1/tenants")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      request = Net::HTTP::Get.new(url)
      request['Content-Type'] = 'application/json'
      request['Authorization'] = "Bearer #{access_token}"

      response = https.request(request)
      if response.code == '200'
        { success: true, data: JSON.parse(response.body) }
      else
        Rails.logger.error "#{self.class} - #{response.code}"
        Rails.logger.error response.body
        { success: false }
      end
    end

    # Fetches tenant details from Kylas using api key
    #
    # @param [string] new_kylas_api_key - API key of tenant from Kylas
    #
    # @return [Object] Response
    #
    def fetch_details_using_api_key(new_kylas_api_key:, tenant:)
      return { success: false, message: I18n.t('tenants.blank_api_key') } if new_kylas_api_key.blank?

      url = URI("#{KylasEngine::KYLAS_AUTH_CONFIG[:kylas_host]}/v1/tenants")
      https = Net::HTTP.new(url.host, url.port)
      https.use_ssl = true
      request = Net::HTTP::Get.new(url)
      request['Content-Type'] = 'application/json'
      request['User-Agent'] = KylasEngine::KylasUserAgent.new(tenant: tenant, agent_type: 'api_key').get_agent
      request['api-key'] = new_kylas_api_key

      response = https.request(request)

      case response.code
      when '200'
        { success: true, data: JSON.parse(response.body) }
      when '400'
        { success: false, message: JSON.parse(response.body)['message'] }
      else
        Rails.logger.error "#{self.class} - #{response.code}"
        Rails.logger.error response.body
        { success: false, message: I18n.t('something_went_wrong') }
      end
    rescue JSON::ParserError => e
      Rails.logger.error "#{self.class} - Message -#{e.message}"
      { success: false, message: I18n.t('something_went_wrong') }
    end
  end
end
