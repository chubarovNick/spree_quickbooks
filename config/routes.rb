Spree::Core::Engine.routes.draw do
  namespace :admin do
    resource :quickbooks, only: [:show, :edit, :update] do
      resource :products_syncs, only: :create, module: :quickbooks
      collection do
        get :authenticate
        get :oauth_callback
      end
    end
  end
end
