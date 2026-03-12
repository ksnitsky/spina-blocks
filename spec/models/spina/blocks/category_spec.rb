# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Spina::Blocks::Category, type: :model do
  subject(:category) { build(:spina_blocks_category) }

  describe 'validations' do
    it { is_expected.to be_valid }

    it 'requires a name' do
      category.name = nil
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include("can't be blank")
    end

    it 'requires a label' do
      category.label = nil
      expect(category).not_to be_valid
      expect(category.errors[:label]).to include("can't be blank")
    end

    it 'requires a unique name' do
      create(:spina_blocks_category, name: 'duplicate')
      category.name = 'duplicate'
      expect(category).not_to be_valid
      expect(category.errors[:name]).to include('has already been taken')
    end
  end

  describe 'associations' do
    it 'has many blocks' do
      expect(described_class.reflect_on_association(:blocks).macro).to eq(:has_many)
    end
  end

  describe 'scopes' do
    it '.sorted orders by position' do
      second = create(:spina_blocks_category, position: 2)
      first = create(:spina_blocks_category, position: 1)

      expect(described_class.sorted).to eq([first, second])
    end
  end

  describe '#to_s' do
    it 'returns the label' do
      category.label = 'My Category'
      expect(category.to_s).to eq('My Category')
    end
  end
end
