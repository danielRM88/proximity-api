class CreateFilters < ActiveRecord::Migration[5.1]
  def change
    create_table :filters do |t|
      t.references :chair, null: false, index: { unique: true }, foreign_key: true
      t.json :x
      t.json :y
      t.json :P
      t.json :F
      t.json :V1
      t.json :H
      t.json :V2
      t.float :adjustment_threshold, default: 10
      t.integer :adjustment_count, default: 0
      t.boolean :continuous_adjustment, default: false
    end
  end
end
