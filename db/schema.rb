# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130925142643) do

  create_table "batches", :force => true do |t|
    t.integer  "generation"
    t.integer  "units_per_tray"
    t.integer  "total_trays"
    t.integer  "start_week"
    t.integer  "germinate_week"
    t.integer  "pot_week"
    t.integer  "sale_week"
    t.integer  "expiry_week"
    t.integer  "site_id"
    t.integer  "category_id"
    t.integer  "crop_id"
    t.integer  "type_id"
    t.integer  "size_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
    t.string   "stage"
    t.integer  "year"
  end

  create_table "categories", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "categories", ["name"], :name => "index_categories_on_name", :unique => true

  create_table "crops", :force => true do |t|
    t.string   "name"
    t.integer  "category_id"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "crops", ["name", "category_id"], :name => "index_crops_on_name_and_category_id", :unique => true

  create_table "sites", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sites", ["name"], :name => "index_sites_on_name", :unique => true

  create_table "sizes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sizes", ["name"], :name => "index_sizes_on_name", :unique => true

  create_table "types", :force => true do |t|
    t.string   "name"
    t.integer  "crop_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "types", ["name", "crop_id"], :name => "index_types_on_name_and_crop_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0,  :null => false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.boolean  "is_admin"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

  add_foreign_key "batches", "categories", :name => "batches_category_id_fk", :dependent => :delete
  add_foreign_key "batches", "crops", :name => "batches_crop_id_fk", :dependent => :delete
  add_foreign_key "batches", "sites", :name => "batches_site_id_fk", :dependent => :delete
  add_foreign_key "batches", "sizes", :name => "batches_size_id_fk", :dependent => :delete
  add_foreign_key "batches", "types", :name => "batches_type_id_fk", :dependent => :delete

  add_foreign_key "crops", "categories", :name => "crops_category_id_fk", :dependent => :delete

  add_foreign_key "types", "crops", :name => "types_crop_id_fk", :dependent => :delete

end
