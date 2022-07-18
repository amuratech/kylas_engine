# frozen_string_literal: true

module KylasEngine
  class ApplicationController < ActionController::Base
    helper_method :current_tenant

    def current_tenant
      return unless current_user.present?

      current_user.tenant
    end
  end
end
