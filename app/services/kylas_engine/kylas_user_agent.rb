# frozen_string_literal: true

module KylasEngine
  class KylasUserAgent
    def initialize(tenant:, agent_type:, user: nil)
      @tenant = tenant
      @agent_type = agent_type
      @user = user
    end

    def get_agent
      user_agent = "marketplaceAppId: #{KylasEngine::KYLAS_AUTH_CONFIG[:app_id]}, tenantId: #{@tenant.id}, "
      user_agent + case @agent_type
                   when 'api_key'
                     'apiKey: true'
                   when 'user'
                     "userId: #{@user.id}"
                   end
    end
  end
end
