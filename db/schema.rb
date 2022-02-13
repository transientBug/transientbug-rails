# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2022_02_12_235420) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_trgm"
  enable_extension "plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "color", ["plain", "red", "orange", "yellow", "olive", "green", "teal", "blue", "violet", "purple", "pink", "brown", "grey", "black"]
  create_enum "icon", ["announcement", "help", "info", "warning", "talk", "settings", "alarm", "lab"]
  create_enum "import_type", ["pinboard", "pocket"]

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", precision: nil, null: false
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
    t.datetime "created_at", precision: nil, null: false
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "webpage_id"
    t.text "title"
    t.text "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "uri", default: "", null: false
    t.virtual "search_title", type: :tsvector, as: "to_tsvector('english'::regconfig, COALESCE(title, ''::text))", stored: true
    t.text "uri_breakdowns", default: [], array: true
    t.index ["search_title"], name: "index_bookmarks_on_search_title", using: :gin
    t.index ["uri"], name: "index_bookmarks_on_uri"
    t.index ["uri_breakdowns"], name: "index_bookmarks_on_uri_breakdowns", using: :gin
    t.index ["user_id", "webpage_id"], name: "index_bookmarks_on_user_id_and_webpage_id", unique: true
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
    t.index ["webpage_id"], name: "index_bookmarks_on_webpage_id"
  end

  create_table "bookmarks_offline_caches", id: false, force: :cascade do |t|
    t.bigint "bookmark_id", null: false
    t.bigint "offline_cache_id", null: false
  end

  create_table "bookmarks_tags", force: :cascade do |t|
    t.bigint "bookmark_id", null: false
    t.bigint "tag_id", null: false
  end

  create_table "clockwork_database_events", force: :cascade do |t|
    t.integer "frequency_quantity"
    t.integer "frequency_period"
    t.string "at"
    t.string "job_name"
    t.jsonb "job_arguments"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "error_messages", force: :cascade do |t|
    t.string "key"
    t.text "message"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "error_messages_import_data", id: false, force: :cascade do |t|
    t.bigint "import_data_id", null: false
    t.bigint "error_message_id", null: false
  end

  create_table "error_messages_offline_caches", id: false, force: :cascade do |t|
    t.bigint "offline_cache_id", null: false
    t.bigint "error_message_id", null: false
  end

  create_table "images", force: :cascade do |t|
    t.bigint "user_id"
    t.text "title"
    t.text "tags", default: [], array: true
    t.text "source"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.boolean "disabled", default: false
    t.index ["user_id"], name: "index_images_on_user_id"
  end

  create_table "import_data", force: :cascade do |t|
    t.bigint "user_id"
    t.enum "import_type", enum_type: "import_type"
    t.boolean "complete", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["user_id"], name: "index_import_data_on_user_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.text "code"
    t.text "internal_note"
    t.text "title"
    t.text "description"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "available", default: 1
    t.index ["code"], name: "index_invitations_on_code", unique: true
  end

  create_table "invitations_users", force: :cascade do |t|
    t.bigint "invitation_id", null: false
    t.bigint "user_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["invitation_id"], name: "index_invitations_users_on_invitation_id"
    t.index ["user_id"], name: "index_invitations_users_on_users_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.integer "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_uri", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "revoked_at", precision: nil
    t.string "scopes"
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.integer "resource_owner_id"
    t.bigint "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "owner_id"
    t.string "owner_type"
    t.boolean "official", default: false
    t.boolean "confidential", default: false, null: false
    t.index ["owner_id", "owner_type"], name: "index_oauth_applications_on_owner_id_and_owner_type"
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "offline_caches", force: :cascade do |t|
    t.bigint "webpage_id"
    t.bigint "root_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "bookmark_id"
    t.index ["bookmark_id"], name: "index_offline_caches_on_bookmark_id"
    t.index ["root_id"], name: "index_offline_caches_on_root_id"
    t.index ["webpage_id"], name: "index_offline_caches_on_webpage_id"
  end

  create_table "roles", force: :cascade do |t|
    t.text "name", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "description"
    t.string "permission_keys", default: [], null: false, array: true
    t.index ["name"], name: "index_roles_on_name", unique: true
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.bigint "role_id", null: false
    t.bigint "user_id", null: false
  end

  create_table "service_announcements", force: :cascade do |t|
    t.text "title"
    t.text "message"
    t.text "color_text"
    t.datetime "start_at", precision: nil
    t.datetime "end_at", precision: nil
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "icon_text"
    t.boolean "active", default: true
    t.enum "icon", enum_type: "icon"
    t.enum "color", enum_type: "color"
    t.boolean "logged_in_only", default: false
  end

  create_table "tags", force: :cascade do |t|
    t.text "label"
    t.text "color"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["label"], name: "index_tags_on_label", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.text "email"
    t.string "password_digest"
    t.text "auth_token"
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "webpages", force: :cascade do |t|
    t.text "uri"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["uri"], name: "index_webpages_on_uri", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "bookmarks", "webpages"
  add_foreign_key "images", "users"
  add_foreign_key "import_data", "users"
  add_foreign_key "invitations_users", "invitations"
  add_foreign_key "invitations_users", "users"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_grants", "users", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id"
  add_foreign_key "offline_caches", "active_storage_attachments", column: "root_id"
  add_foreign_key "offline_caches", "bookmarks", on_delete: :cascade
  add_foreign_key "offline_caches", "webpages"
end
