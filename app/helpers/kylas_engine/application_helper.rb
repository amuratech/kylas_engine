# frozen_string_literal: true

module KylasEngine
  module ApplicationHelper
    def active_class(cont_name)
      controller_name == cont_name ? 'active' : ''
    end

    def create_avatar_name
      return if current_user.blank?

      current_user.name ? current_user.name[0] : current_user.email[0]
    end
  end
end
