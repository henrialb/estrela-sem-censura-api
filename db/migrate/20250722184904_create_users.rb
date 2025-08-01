# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name
      t.string :facebook_id
      t.string :avatar_url

      t.timestamps
    end

    add_index :users, :facebook_id, unique: true
  end
end
