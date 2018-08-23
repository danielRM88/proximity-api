class CreateGroundTruths < ActiveRecord::Migration[5.1]
  def change
    create_table :ground_truths do |t|
      t.references :chair, null: false, index: { unique: true }, foreign_key: true
      t.boolean    :active, default: false, null: false
      t.boolean    :seated, default: false, null: false
      t.string     :gender, limit: 255
      t.float      :height, default: 0.0
      t.float      :weight, default: 0.0
    end
  end
end
