class CreateAlgorithms < ActiveRecord::Migration[5.1]
  def change
    create_table :algorithms do |t|
      t.references :chair, null: false, index: { unique: true }, foreign_key: true
      t.string :algorithm_name, null: false
      t.json :serialized_class, null: false
    end
  end
end
