# frozen_string_literal: true

module KylasEngine
  class Tenant < ApplicationRecord
    # associations
    has_many :users
  end
end
