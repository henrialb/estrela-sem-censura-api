# frozen_string_literal: true

class PostBlueprint < Blueprinter::Base
  identifier :id

  fields :facebook_id, :permalink_url

  field :comments, &:comments
end
