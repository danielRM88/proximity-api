class CreateMeasurements < ActiveRecord::Migration[5.1]
  def change
    create_table :measurements do |t|
      t.float      :value, null: false
      t.references :chair, null: false, index: false, foreign_key: true
      t.references :beacon, null: false, index: false, foreign_key: true
      t.references :prediction, index: false, foreign_key: true

      t.timestamps
    end
  end
end
