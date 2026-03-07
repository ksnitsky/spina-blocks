module Spina
  module Admin
    class BlocksController < AdminController
      admin_section :content

      before_action :set_locale
      before_action :set_block, only: %i[edit edit_content update destroy]
      before_action :set_tabs, only: %i[edit update]

      helper Spina::Admin::PagesHelper

      def index
        add_breadcrumb I18n.t('spina.blocks.title', default: 'Blocks'), spina.admin_blocks_path

        if params[:block_category_id].present?
          @block_category = Spina::BlockCategory.find(params[:block_category_id])
          @blocks = @block_category.blocks.sorted
        else
          @blocks = Spina::Block.sorted
        end

        @block_categories = Spina::BlockCategory.sorted
        @block_templates = current_theme.try(:block_templates) || []
      end

      def new
        @block = Spina::Block.new(block_template: params[:block_template])
      end

      def create
        @block = Spina::Block.new(block_params)
        if @block.save
          redirect_to spina.edit_admin_block_url(@block)
        else
          render turbo_stream: turbo_stream.update(
            helpers.dom_id(@block, :new_block_form),
            partial: 'new_block_form'
          )
        end
      end

      def edit
        add_breadcrumb I18n.t('spina.blocks.title', default: 'Blocks'), spina.admin_blocks_path, class: 'text-gray-400'
        add_breadcrumb @block.title
      end

      def edit_content
        @parts = current_theme.block_templates&.find do |bt|
          bt[:name].to_s == @block.block_template.to_s
        end&.dig(:parts) || []
      end

      def update
        Mobility.locale = @locale
        if @block.update(block_params)
          flash[:success] = I18n.t('spina.blocks.saved', default: 'Block saved')
          redirect_to spina.edit_admin_block_url(@block, params: { locale: @locale })
        else
          add_breadcrumb I18n.t('spina.blocks.title', default: 'Blocks'), spina.admin_blocks_path,
                         class: 'text-gray-400'
          Mobility.locale = I18n.locale
          add_breadcrumb @block.title
          flash.now[:error] = I18n.t('spina.blocks.couldnt_be_saved', default: "Block couldn't be saved")
          render :edit, status: :unprocessable_entity
        end
      end

      def sort
        params[:ids].each.with_index do |id, index|
          Spina::Block.where(id: id).update_all(position: index + 1)
        end

        flash.now[:info] = I18n.t('spina.blocks.sorting_saved', default: 'Sorting saved')
        render_flash
      end

      def destroy
        flash[:info] = I18n.t('spina.blocks.deleted', default: 'Block deleted')
        @block.destroy
        redirect_to spina.admin_blocks_url
      end

      private

      def set_locale
        @locale = params[:locale] || I18n.default_locale
      end

      def set_block
        @block = Spina::Block.find(params[:id])
      end

      def set_tabs
        @tabs = %w[block_content block_settings]
      end

      def block_params
        params.require(:block).permit!
      end
    end
  end
end
