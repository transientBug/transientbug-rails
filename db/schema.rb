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

ActiveRecord::Schema.define(version: 2018_01_13_204714) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "authorizations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "provider"
    t.string "uid"
    t.string "name"
    t.string "nickname"
    t.string "email"
    t.string "image"
    t.string "token"
    t.string "secret"
    t.boolean "expires"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_authorizations_on_user_id"
  end

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "webpage_id"
    t.text "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
    t.index ["webpage_id"], name: "index_bookmarks_on_webpage_id"
  end

  create_table "bookmarks_tags", id: false, force: :cascade do |t|
    t.bigint "bookmark_id", null: false
    t.bigint "tag_id", null: false
  end

  create_table "clockwork_database_events", force: :cascade do |t|
    t.integer "frequency_quantity"
    t.integer "frequency_period"
    t.string "at"
    t.string "job_name"
    t.jsonb "job_arguments"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "images", force: :cascade do |t|
    t.bigint "user_id"
    t.text "title"
    t.text "tags", default: [], array: true
    t.text "source"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "disabled", default: false
    t.index ["user_id"], name: "index_images_on_user_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.text "code"
    t.text "internal_note"
    t.text "title"
    t.text "description"
    t.integer "limit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "available"
    t.integer "current"
    t.index ["code"], name: "index_invitations_on_code", unique: true
  end

  create_table "invitations_users", force: :cascade do |t|
    t.bigint "invitation_id", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invitation_id"], name: "index_invitations_users_on_invitation_id"
    t.index ["user_id"], name: "index_invitations_users_on_users_id"
  end

  create_table "service_announcements", force: :cascade do |t|
    t.text "title"
    t.text "message"
    t.text "color"
    t.datetime "start_at"
    t.datetime "end_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tags", force: :cascade do |t|
    t.text "label"
    t.text "color"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "email"
    t.string "password_digest"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "webpages", force: :cascade do |t|
    t.text "uri_string"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "authorizations", "users"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "bookmarks", "webpages"
  add_foreign_key "images", "users"
  add_foreign_key "invitations_users", "invitations"
  add_foreign_key "invitations_users", "users"
end
