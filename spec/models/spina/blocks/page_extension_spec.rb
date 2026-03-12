# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spina::Blocks::PageExtension, type: :model do
  describe 'inclusion in Spina::Page' do
    it 'is included in Spina::Page' do
      expect(Spina::Page.ancestors).to include(described_class)
    end
  end

  describe 'associations added to Spina::Page' do
    it 'adds has_many :page_blocks' do
      association = Spina::Page.reflect_on_association(:page_blocks)
      expect(association).not_to be_nil
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it 'adds has_many :blocks through :page_blocks' do
      association = Spina::Page.reflect_on_association(:blocks)
      expect(association).not_to be_nil
      expect(association.macro).to eq(:has_many)
      expect(association.options[:through]).to eq(:page_blocks)
    end
  end

  describe 'functional test' do
    let(:page) { create(:spina_page) }
    let(:block) { create(:spina_blocks_block) }

    it 'allows assigning blocks to a page' do
      create(:spina_blocks_page_block, page: page, block: block)

      page.reload
      expect(page.blocks).to include(block)
      expect(page.page_blocks.count).to eq(1)
    end
  end
end
