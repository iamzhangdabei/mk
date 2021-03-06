Mk::Application.routes.draw do
  resources :volume_snapshots
  resources :server_snapshots
  resources :volumes do
    member do
      post 'attach'
      get "create_snapshot"
      post "make_snapshot"
    end
  end

  match "page/:action" => "page"
  resources :tenants do
    resources :flavors
    resources :images
    resources :servers do
      member do 
        get "create_snapshot"
        post "make_snapshot"
      end
    end
    resources :volumes
    resources :volume_snapshots
    resources :users
  resources :server_snapshots
    match "/quotas/edit" => "quotas#edit"
    resources :snapshots
    resources :users do
member do 
get :roles
end
    end
  end
  resources :tenants

  resources :flavors

  resources :images

  resources :servers do
    member do 
      get "create_snapshot"
      post "make_snapshot"
    end
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.
  match 'users/check'=> "users#check"
  match '/logout' => 'user_sessions#destroy', :as => :logout
  match '/login' => 'user_sessions#new', :as => :login
  match '/register' => 'users#create', :as => :register
  match '/signup' => 'users#new', :as => :signup
  resource :user_sessions

  resources :users
  
  namespace :admin do
    root :to => 'users#index'
    resource :users
  end
  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
   root :to => 'user_sessions#new'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
