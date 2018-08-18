class CreatePredictions < ActiveRecord::Migration[5.1]
  def change
    create_table :predictions do |t|
      t.float      :filter_result
      t.float      :filter_variance
      t.float      :algorithm_result, null: false
      t.boolean    :seated, null: false
      t.references :chair, null: false, foreign_key: true

      t.timestamps
    end
  end
end
