class AddScoreColumnsToMovies < ActiveRecord::Migration[5.0]
  def change
    add_column :movies, :total_score, :bigint, default: 0
    add_column :movies, :avg_score, :float, default: 0
    add_column :movies, :votes_number, :integer, default: 0
  end
end
