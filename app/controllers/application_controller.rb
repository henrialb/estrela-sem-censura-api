# frozen_string_literal: true

class ApplicationController < ActionController::API
  attr_reader :current_user

  private

  def authenticate_user!
    token = request.headers['Authorization']&.gsub(/^Bearer /, '')

    return render json: { error: 'No token provided' }, status: :unauthorized unless token

    begin
      decoded_token = JWT.decode(token, Rails.application.secret_key_base, true, algorithm: 'HS256')

      @current_user = User.find(decoded_token[0]['user_id'])
    rescue JWT::DecodeError, ActiveRecord::RecordNotFound
      render json: { error: 'Invalid token' }, status: :unauthorized
    end
  end
end
