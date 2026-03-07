Spina::Page.class_eval do
  has_many :page_blocks, class_name: 'Spina::PageBlock', foreign_key: :page_id, dependent: :destroy
  has_many :blocks, through: :page_blocks, class_name: 'Spina::Block'
end
