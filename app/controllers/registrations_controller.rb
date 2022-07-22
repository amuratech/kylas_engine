# frozen_string_literal: true

class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, only: [:create]

  def create
    build_resource(sign_up_params)
    set_accessor_create_tenant
    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message! :notice, :signed_up_but_unconfirmed
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  def after_inactive_sign_up_path_for(resource)
    "#{kylas_engine_path}#{new_user_session_path}"
  end

  alias after_sign_up_path_for after_inactive_sign_up_path_for

  private

  def set_accessor_create_tenant
    resource.create_tenant = true
  end
end
