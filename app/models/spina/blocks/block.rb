# frozen_string_literal: true

module Spina
  module Blocks
    class Block < ApplicationRecord
      include AttrJson::Record
      include AttrJson::NestedAttributes
      include Spina::Partable
      include Spina::TranslatedContent

      belongs_to :category, class_name: "Spina::Blocks::Category", optional: true
      has_many :page_blocks, class_name: "Spina::Blocks::PageBlock", dependent: :destroy
      has_many :pages, through: :page_blocks, class_name: "Spina::Page"

      before_destroy :ensure_deletable

      validates :name, presence: true
      validates :block_template, presence: true
      validates :key, uniqueness: { allow_nil: true }
      validate :key_must_not_change, on: :update

      scope :active, -> { where(active: true) }
      scope :sorted, -> { order(:position) }
      scope :deletable, -> { where(deletable: true) }
      scope :undeletable, -> { where(deletable: false) }

      def to_s
        name
      end

      # Whether this block is a system (custom) block with an immutable key
      def system?
        key.present?
      end

      private

      def ensure_deletable
        unless deletable?
          errors.add(:base, :undeletable)
          throw(:abort)
        end
      end

      def key_must_not_change
        if key_was.present? && key_changed?
          errors.add(:key, :immutable)
        end
      end
    end
  end
end
