# frozen_string_literal: true

module KylasEngine
  class Tenant < ApplicationRecord
    # Encryption
    encrypts :kylas_api_key, :webhook_api_key, deterministic: true

    # associations
    has_many :users

    # callbacks
    before_save :generate_webhook_api_key

    private

    def generate_webhook_api_key
      self.webhook_api_key = SecureRandom.uuid if webhook_api_key.blank?
    end
  end
end
