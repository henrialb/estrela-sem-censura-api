# frozen_string_literal: true

module Api
  class PostsController < ApplicationController
    def index
      posts = Post.includes(:comments).recent

      render json: posts.map { |post|
        build_post_json(post)
      }, status: :ok
    end

    def create
      url = params.permit(:url)[:url]
      post = Post.add_from_url(resolve(url))

      if post.save
        render json: build_post_json(post), status: :created
      else
        render json: { errors: post.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def resolve(url)
      if url.blank?
        render json: { error: 'URL parameter is required' }, status: :bad_request
        return
      end

      begin
        final_url = follow_redirects(url)
      rescue StandardError => e
        render json: { error: "Failed to resolve URL: #{e.message}" }, status: :unprocessable_entity
      end

      final_url
    end

    def follow_redirects(url, max_redirects = 10)
      uri = URI.parse(url)

      max_redirects.times do
        response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
          http.request_head(uri.path.empty? ? '/' : uri.path)
        end

        case response
        when Net::HTTPRedirection
          location = response['location']
          # Handle relative redirects
          uri = location.start_with?('http') ? URI.parse(location) : URI.join(uri, location)
        else
          return uri.to_s
        end
      end

      # If we've exceeded max redirects, return the last URL
      uri.to_s
    end

    def build_post_json(post)
      {
        id: post.id,
        facebook_id: post.facebook_id,
        permalink_url: post.permalink_url,
        comments_count: post.comments.count,
        created_at: post.created_at,
        comments: post.comments.map do |comment|
          {
            id: comment.id,
            content: comment.content,
            created_at: comment.created_at,
            user: {
              name: comment.user.name,
              avatar_url: comment.user.avatar_url
            }
          }
        end
      }
    end
  end
end
