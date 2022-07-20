# frozen_string_literal: true

module KylasEngine
  class Tenant < ApplicationRecord
    # associations
    has_many :users

    # callbacks
    before_save :generate_webhook_api_key

    private

    def generate_webhook_api_key
      self.webhook_api_key ||= SecureRandom.uuid
    end
  end
end
