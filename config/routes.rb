Spina::Engine.routes.draw do
  namespace :admin, path: Spina.config.backend_path do
    resources :blocks do
      member do
        get :edit_content
      end

      collection do
        post :sort
      end
    end

    resources :block_categories, only: %i[index edit update]

    resources :pages, only: [] do
      resources :page_blocks, only: %i[index create destroy] do
        collection do
          post :sort
        end
      end
    end
  end
end
