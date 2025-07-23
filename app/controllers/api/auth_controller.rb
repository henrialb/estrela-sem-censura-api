# frozen_string_literal: true

module Api
  class AuthController < ApplicationController
    def facebook
      # Validate the Facebook access token with Facebook's API
      facebook_user = validate_facebook_token(params[:access_token])

      if facebook_user
        # Find or create user
        user = User.find_or_create_by(facebook_id: facebook_user['id']) do |u|
          u.name = facebook_user['name']
          u.facebook_id = facebook_user['id']
          u.avatar_url = facebook_user['picture']['data']['url']
        end

        if user.persisted?
          # Generate JWT token
          token = generate_jwt_token(user)
          render json: { token: token, user: { name: user.name, avatar_url: user.avatar_url } }
        else
          render json: { error: 'Failed to create user' }, status: :unprocessable_content
        end
      else
        render json: { error: 'Invalid Facebook token' }, status: :unauthorized
      end
    end

    private

    def validate_facebook_token(access_token)
      # Validate token with Facebook's Graph API
      conn = Faraday.new(url: 'https://graph.facebook.com')

      response = conn.get('/me') do |req|
        req.params['access_token'] = access_token
        req.params['fields'] = 'id,name,picture'
      end

      JSON.parse(response.body) if response.success?
    rescue JSON::ParserError, Faraday::Error
      nil
    end

    def generate_jwt_token(user)
      payload = {
        user_id: user.id,
        exp: 1.week.from_now.to_i
      }
      JWT.encode(payload, Rails.application.secret_key_base)
    end
  end
end
