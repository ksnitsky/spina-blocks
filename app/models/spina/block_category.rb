module Spina
  class BlockCategory < ApplicationRecord
    has_many :blocks, class_name: 'Spina::Block', dependent: :nullify

    validates :name, presence: true, uniqueness: true
    validates :label, presence: true

    scope :sorted, -> { order(:position) }

    def to_s
      label
    end
  end
end
