# frozen_string_literal: true

module Api
  class CommentsController < ApplicationController
    before_action :authenticate_user!, only: [:create]
    before_action :find_post

    def create
      comment = @post.comments.build(comment_params)
      comment.user = current_user

      if comment.save
        render json: {
          id: comment.id,
          content: comment.content,
          created_at: comment.created_at,
          user: {
            id: current_user.id,
            name: current_user.name,
            avatar_url: current_user.avatar_url
          }
        }, status: :created
      else
        render json: { errors: comment.errors.full_messages }, status: :unprocessable_entity
      end
    end

    private

    def find_post
      @post = Post.find(params[:post_id])
    end

    def comment_params
      params.expect(comment: [:content])
    end
  end
end
