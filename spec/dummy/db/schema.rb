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

ActiveRecord::Schema[8.1].define(version: 2026_03_13_150905) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_mailbox_inbound_emails", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "message_checksum", null: false
    t.string "message_id", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["message_id", "message_checksum"], name: "index_action_mailbox_inbound_emails_uniqueness", unique: true
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "spina_accounts", id: :serial, force: :cascade do |t|
    t.string "address"
    t.string "city"
    t.datetime "created_at", precision: nil, null: false
    t.string "email"
    t.jsonb "json_attributes"
    t.string "name"
    t.string "phone"
    t.string "postal_code"
    t.text "preferences"
    t.boolean "robots_allowed", default: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_attachment_collections", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_attachment_collections_attachments", id: :serial, force: :cascade do |t|
    t.integer "attachment_collection_id"
    t.integer "attachment_id"
  end

  create_table "spina_attachments", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "file"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_blocks_blocks", force: :cascade do |t|
    t.boolean "active", default: true
    t.string "block_template", null: false
    t.bigint "category_id"
    t.datetime "created_at", null: false
    t.json "json_attributes"
    t.string "name", null: false
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_spina_blocks_blocks_on_category_id"
    t.index ["name"], name: "index_spina_blocks_blocks_on_name", unique: true
  end

  create_table "spina_blocks_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "label", null: false
    t.string "name", null: false
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_spina_blocks_categories_on_name", unique: true
  end

  create_table "spina_blocks_page_blocks", force: :cascade do |t|
    t.bigint "block_id", null: false
    t.datetime "created_at", null: false
    t.bigint "page_id", null: false
    t.integer "position", default: 0
    t.datetime "updated_at", null: false
    t.index ["block_id"], name: "index_spina_blocks_page_blocks_on_block_id"
    t.index ["page_id", "block_id"], name: "index_spina_blocks_page_blocks_on_page_id_and_block_id", unique: true
    t.index ["page_id"], name: "index_spina_blocks_page_blocks_on_page_id"
  end

  create_table "spina_image_collections", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_image_collections_images", id: :serial, force: :cascade do |t|
    t.integer "image_collection_id"
    t.integer "image_id"
    t.integer "position"
    t.index ["image_collection_id"], name: "index_spina_image_collections_images_on_image_collection_id"
    t.index ["image_id"], name: "index_spina_image_collections_images_on_image_id"
  end

  create_table "spina_images", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "media_folder_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["media_folder_id"], name: "index_spina_images_on_media_folder_id"
  end

  create_table "spina_layout_parts", id: :serial, force: :cascade do |t|
    t.integer "account_id"
    t.datetime "created_at", precision: nil
    t.integer "layout_partable_id"
    t.string "layout_partable_type"
    t.string "name"
    t.string "title"
    t.datetime "updated_at", precision: nil
  end

  create_table "spina_line_translations", id: :serial, force: :cascade do |t|
    t.string "content"
    t.datetime "created_at", precision: nil, null: false
    t.string "locale", null: false
    t.integer "spina_line_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["locale"], name: "index_spina_line_translations_on_locale"
    t.index ["spina_line_id"], name: "index_spina_line_translations_on_spina_line_id"
  end

  create_table "spina_lines", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "spina_media_folders", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_navigation_items", id: :serial, force: :cascade do |t|
    t.string "ancestry"
    t.datetime "created_at", precision: nil
    t.string "kind", default: "page", null: false
    t.integer "navigation_id", null: false
    t.integer "page_id"
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", precision: nil
    t.string "url"
    t.string "url_title"
    t.index ["page_id", "navigation_id"], name: "index_spina_navigation_items_on_page_id_and_navigation_id", unique: true
  end

  create_table "spina_navigations", id: :serial, force: :cascade do |t|
    t.boolean "auto_add_pages", default: false, null: false
    t.datetime "created_at", precision: nil
    t.string "label", null: false
    t.string "name", null: false
    t.integer "position", default: 0, null: false
    t.datetime "updated_at", precision: nil
    t.index ["name"], name: "index_spina_navigations_on_name", unique: true
  end

  create_table "spina_options", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "value"
  end

  create_table "spina_page_parts", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "name"
    t.integer "page_id"
    t.integer "page_partable_id"
    t.string "page_partable_type"
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "spina_page_translations", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "description"
    t.string "locale", null: false
    t.string "materialized_path"
    t.string "menu_title"
    t.string "seo_title"
    t.integer "spina_page_id", null: false
    t.string "title"
    t.datetime "updated_at", precision: nil, null: false
    t.string "url_title"
    t.index ["locale"], name: "index_spina_page_translations_on_locale"
    t.index ["spina_page_id"], name: "index_spina_page_translations_on_spina_page_id"
  end

  create_table "spina_pages", id: :serial, force: :cascade do |t|
    t.boolean "active", default: true
    t.string "ancestry"
    t.integer "ancestry_children_count"
    t.integer "ancestry_depth", default: 0
    t.datetime "created_at", precision: nil, null: false
    t.boolean "deletable", default: true
    t.boolean "draft", default: false
    t.jsonb "json_attributes"
    t.string "layout_template"
    t.string "link_url"
    t.string "name"
    t.integer "position"
    t.integer "resource_id"
    t.boolean "show_in_menu", default: true
    t.boolean "skip_to_first_child", default: false
    t.string "slug"
    t.datetime "updated_at", precision: nil, null: false
    t.string "view_template"
    t.index ["resource_id"], name: "index_spina_pages_on_resource_id"
  end

  create_table "spina_resources", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "label"
    t.string "name", null: false
    t.string "order_by"
    t.jsonb "slug", default: {}
    t.datetime "updated_at", precision: nil, null: false
    t.string "view_template"
  end

  create_table "spina_rewrite_rules", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "new_path"
    t.string "old_path"
    t.datetime "updated_at", precision: nil
  end

  create_table "spina_settings", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "plugin"
    t.jsonb "preferences", default: {}
    t.datetime "updated_at", precision: nil, null: false
    t.index ["plugin"], name: "index_spina_settings_on_plugin"
  end

  create_table "spina_structure_items", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.integer "position"
    t.integer "structure_id"
    t.datetime "updated_at", precision: nil
    t.index ["structure_id"], name: "index_spina_structure_items_on_structure_id"
  end

  create_table "spina_structure_parts", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.string "name"
    t.integer "structure_item_id"
    t.integer "structure_partable_id"
    t.string "structure_partable_type"
    t.string "title"
    t.datetime "updated_at", precision: nil
    t.index ["structure_item_id"], name: "index_spina_structure_parts_on_structure_item_id"
    t.index ["structure_partable_id"], name: "index_spina_structure_parts_on_structure_partable_id"
  end

  create_table "spina_structures", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "spina_text_translations", id: :serial, force: :cascade do |t|
    t.text "content"
    t.datetime "created_at", precision: nil, null: false
    t.string "locale", null: false
    t.integer "spina_text_id", null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["locale"], name: "index_spina_text_translations_on_locale"
    t.index ["spina_text_id"], name: "index_spina_text_translations_on_spina_text_id"
  end

  create_table "spina_texts", id: :serial, force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "spina_users", id: :serial, force: :cascade do |t|
    t.boolean "admin", default: false
    t.datetime "created_at", precision: nil, null: false
    t.string "email"
    t.datetime "last_logged_in", precision: nil
    t.string "name"
    t.string "password_digest"
    t.datetime "password_reset_sent_at", precision: nil
    t.string "password_reset_token"
    t.datetime "updated_at", precision: nil, null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "spina_blocks_blocks", "spina_blocks_categories", column: "category_id"
  add_foreign_key "spina_blocks_page_blocks", "spina_blocks_blocks", column: "block_id"
  add_foreign_key "spina_blocks_page_blocks", "spina_pages", column: "page_id"
end
