# frozen_string_literal: true

require 'net/http'

module KylasEngine
  class UserDetails
    def initialize(user:)
      @user = user
    end

    def call
      access_token = @user.fetch_access_token
      return { success: false } if access_token.nil?

      url = URI("#{KylasEngine::KYLAS_AUTH_CONFIG[:kylas_host]}/v1/users/me")
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
  end
end
