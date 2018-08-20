class CreateCalibrations < ActiveRecord::Migration[5.1]
  def change
    create_table :calibrations do |t|
      t.references :chair, null: false, index: { unique: true }, foreign_key: true
      t.boolean    :calibrated, default: false, null: false
      t.boolean    :ongoing, default: false, null: false
      t.integer    :records_to_calibrate, default: 100, null: false
    end
  end
end
