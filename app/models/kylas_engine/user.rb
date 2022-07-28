# frozen_string_literal: true

module KylasEngine
  class User < ApplicationRecord
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :validatable, :confirmable

    attr_accessor :create_tenant

    # validations
    validates :name, presence: true
    validates :kylas_user_id, uniqueness: true, allow_blank: true

    # associations
    belongs_to :tenant

    # callbacks
    before_validation :create_tenant!

    # Encryption
    encrypts :kylas_access_token, :kylas_refresh_token

    # new function to return whether a password has been set
    def has_no_password?
      encrypted_password.blank?
    end

    # new function to set the password without knowing the current
    # password used in our confirmation controller.
    def attempt_set_password(params)
      p = {}
      p[:password] = params[:password]
      p[:password_confirmation] = params[:password_confirmation]
      update(p)
    end

    def update_tokens_details!(response = {})
      return if response.blank?

      update(
        kylas_access_token: response[:access_token],
        kylas_refresh_token: response[:refresh_token],
        kylas_access_token_expires_at: Time.at(DateTime.now.to_i + response[:expires_in])
      )
    end

    def update_users_and_tenants_details
      fetch_and_save_kylas_user_id
      fetch_and_save_kylas_tenant_id
    end

    def fetch_access_token
      return kylas_access_token if access_token_valid?

      response = KylasEngine::GetAccessToken.new(kylas_refresh_token: kylas_refresh_token).call

      return unless response[:success]

      update_tokens_details!(response)
      kylas_access_token
    end

    def access_token_valid?
      (kylas_access_token_expires_at.to_i > DateTime.now.to_i)
    end

    # Checks if the user is active or not before log in
    def active_for_authentication?
      super && active?
    end

    # Message to show when user is not active while log in
    def inactive_message
      !active? && confirmed? ? I18n.t('users.deactivated_user_log_in_message') : super
    end

    # Deactivates the user
    def deactivate
      update(active: false)
    end

    # Activates the user
    def activate
      update(active: true)
    end

    private

    def create_tenant!
      return unless create_tenant

      self.is_tenant = true
      self.tenant = Tenant.create
    end

    def fetch_and_save_kylas_user_id
      return if kylas_access_token.blank?

      begin
        response = KylasEngine::UserDetails.new(user: self).call
        update!(kylas_user_id: response.dig(:data, 'id')) if response[:success]
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "#{self.class} - Exception - #{e}"
        Rails.logger.error "User id - #{id}"
      end
    end

    def fetch_and_save_kylas_tenant_id
      return if kylas_access_token.blank?

      begin
        response = KylasEngine::TenantDetails.new(user: self).call
        if response[:success]
          tenant.update!(kylas_tenant_id: response.dig(:data, 'id'), timezone: response.dig(:data, 'timezone'))
        end
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.error "#{self.class} - Exception - #{e}"
        Rails.logger.error "User id - #{id}"
      end
    end
  end
end
