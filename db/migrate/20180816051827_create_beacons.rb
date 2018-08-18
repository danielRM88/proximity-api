class CreateBeacons < ActiveRecord::Migration[5.1]
  def change
    create_table :beacons do |t|
      t.string     :mac_address, null: false, limit: 100
      t.string     :brand, limit: 200
      t.string     :model, limit: 200
      t.references :chair, null: true, foreign_key: true

      t.timestamps

      t.index [:mac_address], unique: true
    end
  end
end
