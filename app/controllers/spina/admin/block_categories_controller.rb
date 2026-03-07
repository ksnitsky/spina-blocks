module Spina
  module Admin
    class BlockCategoriesController < AdminController
      admin_section :content

      def index
        @block_categories = Spina::BlockCategory.sorted
      end

      def edit
        @block_category = Spina::BlockCategory.find(params[:id])
        add_breadcrumb I18n.t('spina.blocks.title', default: 'Blocks'), spina.admin_blocks_path, class: 'text-gray-400'
        add_breadcrumb @block_category.label
      end

      def update
        @block_category = Spina::BlockCategory.find(params[:id])
        if @block_category.update(block_category_params)
          flash[:success] = I18n.t('spina.block_categories.saved', default: 'Category saved')
          redirect_to spina.admin_blocks_url
        else
          flash.now[:error] = I18n.t('spina.block_categories.couldnt_be_saved', default: "Category couldn't be saved")
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def block_category_params
        params.require(:block_category).permit(:name, :label, :position)
      end
    end
  end
end
