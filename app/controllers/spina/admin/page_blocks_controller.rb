module Spina
  module Admin
    class PageBlocksController < AdminController
      admin_section :content

      before_action :set_page

      def index
        add_breadcrumb I18n.t('spina.website.pages', default: 'Pages'), spina.admin_pages_path, class: 'text-gray-400'
        add_breadcrumb @page.title, spina.edit_admin_page_path(@page), class: 'text-gray-400'
        add_breadcrumb I18n.t('spina.page_blocks.title', default: 'Page Blocks')

        @page_blocks = @page.page_blocks.sorted.includes(:block)
        @available_blocks = Spina::Block.active.sorted.where.not(id: @page.block_ids)
      end

      def create
        @page_block = @page.page_blocks.build(page_block_params)
        @page_block.position = @page.page_blocks.maximum(:position).to_i + 1

        if @page_block.save
          flash[:success] = I18n.t('spina.page_blocks.added', default: 'Block added to page')
        else
          flash[:error] = I18n.t('spina.page_blocks.couldnt_be_added', default: "Block couldn't be added")
        end

        redirect_to spina.admin_page_blocks_url(page_id: @page.id)
      end

      def destroy
        @page_block = @page.page_blocks.find(params[:id])
        @page_block.destroy
        flash[:info] = I18n.t('spina.page_blocks.removed', default: 'Block removed from page')
        redirect_to spina.admin_page_blocks_url(page_id: @page.id)
      end

      def sort
        params[:ids].each.with_index do |id, index|
          @page.page_blocks.where(id: id).update_all(position: index + 1)
        end

        flash.now[:info] = I18n.t('spina.page_blocks.sorting_saved', default: 'Sorting saved')
        render_flash
      end

      private

      def set_page
        @page = Spina::Page.find(params[:page_id])
      end

      def page_block_params
        params.require(:page_block).permit(:block_id)
      end
    end
  end
end
