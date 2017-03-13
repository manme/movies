class CreateMovies < ActiveRecord::Migration[5.0]
  def change
    create_table :movies do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.references :user, null: false
      t.boolean :is_deleted, default: false

      t.timestamps
    end
  end
end
