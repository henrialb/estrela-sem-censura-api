# frozen_string_literal: true

class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :facebook_id, null: false
      t.string :permalink_url, null: false

      t.timestamps
    end

    add_index :posts, :facebook_id, unique: true
  end
end
