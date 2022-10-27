# frozen_string_literal: true

require 'devise'
require 'kylas_engine/version'
require 'kylas_engine/engine'

module KylasEngine
  KYLAS_AUTH_CONFIG = {}

  module Context
    def self.setup(client_id:, client_secret:, redirect_uri:, kylas_host:, app_id:)
      KYLAS_AUTH_CONFIG[:client_id] = client_id
      KYLAS_AUTH_CONFIG[:client_secret] = client_secret
      KYLAS_AUTH_CONFIG[:redirect_uri] = redirect_uri
      KYLAS_AUTH_CONFIG[:kylas_host] = kylas_host
      KYLAS_AUTH_CONFIG[:app_id] = app_id
    end
  end
end
