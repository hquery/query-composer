QueryComposer::Application.routes.draw do

  devise_for :users

  get "admin/users"
  post "admin/promote"
  post "admin/demote"
  post "admin/approve"
  post "admin/disable"
  
  get "endpoints/refresh_endpoint_statuses"
  post 'queries/generate_query'

  resources :endpoints
  resources :library_functions
  resources :template_queries

  post "queries/clone_template"
  resources :queries do
    member do
      post 'execute'
      delete 'destroy'
      get 'log'
      get 'refresh_execution_results'
      get 'execution_history'
      get 'cancel'
      get 'cancel_execution'
      get 'builder'
      get 'builder_simple'
      get 'edit_code'
      get 'result'
    end
    collection do
      get 'execute_batch'
    end
  end
  
  
  resources :code_sets do

  end
  
  namespace :code_sets do
    get "by_type/:type", :action=>:by_type
  end
  
  root :to => 'queries#index'

  

  # The priority is based upon order of creation:
  # first created -> highest priority.

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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
