# frozen_string_literal: true

module Api
  class UsersController < ApplicationController
    before_action :authenticate_user!

    def me
      render json: {
        name: current_user.name,
        avatar_url: current_user.avatar_url
      }
    end
  end
end
