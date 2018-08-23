class CreateGroundTruthValues < ActiveRecord::Migration[5.1]
  def change
    create_table :ground_truth_values do |t|
      t.references :prediction, null: false, index: { unique: true }, foreign_key: true
      t.boolean    :seated, default: false, null: false
      t.string     :gender, limit: 255
      t.float      :height, default: 0.0
      t.float      :weight, default: 0.0
    end
  end
end
