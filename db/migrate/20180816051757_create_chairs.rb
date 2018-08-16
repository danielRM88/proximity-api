class CreateChairs < ActiveRecord::Migration[5.1]
  def change
    create_table :chairs do |t|
      t.string :name, null: false, limit: 100
      t.string :notes, limit: 255

      t.timestamps

      t.index [:name], unique: true
    end
  end
end
