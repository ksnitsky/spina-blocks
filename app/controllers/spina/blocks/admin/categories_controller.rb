module Spina
  module Blocks
    module Admin
      class CategoriesController < ::Spina::Admin::AdminController
        admin_section :content

        def index
          @categories = Spina::Blocks::Category.sorted
        end

        def edit
          @category = Spina::Blocks::Category.find(params[:id])
          add_breadcrumb I18n.t('spina.blocks.title'), spina.blocks_admin_blocks_path, class: 'text-gray-400'
          add_breadcrumb @category.label
        end

        def update
          @category = Spina::Blocks::Category.find(params[:id])
          if @category.update(category_params)
            flash[:success] = I18n.t('spina.block_categories.saved')
            redirect_to spina.blocks_admin_blocks_url
          else
            flash.now[:error] = I18n.t('spina.block_categories.couldnt_be_saved')
            render :edit, status: :unprocessable_entity
          end
        end

        private

        def category_params
          params.require(:category).permit(:name, :label, :position)
        end
      end
    end
  end
end
