# frozen_string_literal: true

module KylasEngine
  class User < ApplicationRecord
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :validatable, :confirmable

    attr_accessor :create_tenant, :skip_password_validation

    # validations
    validates :name, presence: true
    validates :kylas_user_id, uniqueness: true, allow_blank: true

    # associations
    belongs_to :tenant

    # callbacks
    before_validation :create_tenant!

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

    def password_match?
      errors[:password] << I18n.t('errors.messages.blank') if password.blank?
      errors[:password_confirmation] << I18n.t('errors.messages.blank') if password_confirmation.blank?
      if password != password_confirmation
        errors[:password_confirmation] << I18n.translate('errors.messages.confirmation', attribute: 'password')
      end
      password == password_confirmation && !password.blank?
    end

    # Devise::Models:unless_confirmed` method doesn't exist in Devise 2.0.0 anymore.
    # Instead you should use `pending_any_confirmation`.
    def only_if_unconfirmed
      pending_any_confirmation { yield }
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

    protected

    def password_required?
      return false if skip_password_validation

      super
    end

    private

    def create_tenant!
      return unless create_tenant

      self.is_tenant = true
      self.tenant = Tenant.create
    end
  end
end
