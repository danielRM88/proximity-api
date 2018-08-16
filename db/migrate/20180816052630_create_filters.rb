class CreateFilters < ActiveRecord::Migration[5.1]
  def change
    create_table :filters do |t|
      t.references :chair, null: false, index: { unique: true }, foreign_key: true
    end
  end
end