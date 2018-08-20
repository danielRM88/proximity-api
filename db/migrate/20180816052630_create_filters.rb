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
    end
  end
end