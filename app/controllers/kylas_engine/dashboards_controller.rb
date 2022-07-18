# frozen_string_literal: true

module KylasEngine
  class DashboardsController < ApplicationController
    before_action :authenticate_user!

    def help; end
  end
end
