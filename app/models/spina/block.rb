module Spina
  class Block < ApplicationRecord
    include AttrJson::Record
    include AttrJson::NestedAttributes
    include Partable
    include TranslatedContent

    belongs_to :block_category, class_name: 'Spina::BlockCategory', optional: true
    has_many :page_blocks, class_name: 'Spina::PageBlock', dependent: :destroy
    has_many :pages, through: :page_blocks, class_name: 'Spina::Page'

    validates :title, presence: true
    validates :name, presence: true, uniqueness: true
    validates :block_template, presence: true

    scope :active, -> { where(active: true) }
    scope :sorted, -> { order(:position) }

    def to_s
      title
    end
  end
end
