# frozen_string_literal: true

module KylasEngine
  module DeviseRequestSpecHelpers
    include ::Warden::Test::Helpers

    def sign_in_resource(resource_or_scope, resource = nil)
      resource ||= resource_or_scope
      scope = Devise::Mapping.find_scope!(resource_or_scope)
      login_as(resource, scope: scope)
    end

    def sign_out_resource(resource_or_scope)
      scope = Devise::Mapping.find_scope!(resource_or_scope)
      logout(scope)
    end

    def execute_with_resource_sign_in(resource_or_scope, &block)
      sign_in_resource(resource_or_scope)
      yield
      sign_out_resource(resource_or_scope)
    end
  end
end
