# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180816064247) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "beacons", force: :cascade do |t|
    t.string "mac_address", limit: 100, null: false
    t.string "brand", limit: 200
    t.string "model", limit: 200
    t.bigint "chair_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chair_id"], name: "index_beacons_on_chair_id"
    t.index ["mac_address"], name: "index_beacons_on_mac_address", unique: true
  end

  create_table "calibrations", force: :cascade do |t|
    t.bigint "chair_id", null: false
    t.boolean "calibrated", default: false, null: false
    t.integer "records_to_calibrate", default: 100, null: false
    t.index ["chair_id"], name: "index_calibrations_on_chair_id", unique: true
  end

  create_table "chairs", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "notes", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_chairs_on_name", unique: true
  end

  create_table "filters", force: :cascade do |t|
    t.bigint "chair_id", null: false
    t.index ["chair_id"], name: "index_filters_on_chair_id", unique: true
  end

  create_table "measurements", force: :cascade do |t|
    t.float "value", null: false
    t.bigint "chair_id", null: false
    t.bigint "beacon_id", null: false
    t.bigint "prediction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "predictions", force: :cascade do |t|
    t.float "filter_result"
    t.float "filter_variance"
    t.float "algorithm_result", null: false
    t.boolean "seated", null: false
    t.bigint "chair_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chair_id"], name: "index_predictions_on_chair_id"
  end

  add_foreign_key "beacons", "chairs"
  add_foreign_key "calibrations", "chairs"
  add_foreign_key "filters", "chairs"
  add_foreign_key "measurements", "beacons"
  add_foreign_key "measurements", "chairs"
  add_foreign_key "measurements", "predictions"
  add_foreign_key "predictions", "chairs"
end
