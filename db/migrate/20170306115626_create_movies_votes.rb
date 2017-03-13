class CreateMoviesVotes < ActiveRecord::Migration[5.0]
  def change
    create_table :movies_votes do |t|
      t.references :movie, null: false
      t.references :user, null: false
      t.integer :score, default: 0
      t.datetime :created_at
    end

    add_index :movies_votes, [:user_id, :movie_id], unique: true
  end
end
