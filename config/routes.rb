SIM::Application.routes.draw do

  match '/signup',  :to => 'users#new'

#  devise_for :users

  match 'countries_autocomplete/index'
  match '*a/autocomplete/country' => 'autocomplete#country'
  match 'autocomplete/country' 
  match 'autocomplete/family'
  match 'autocomplete/spouse'
  match 'autocomplete_searches/index'
  match 'reports/:action(.:format)' => 'reports#:action'
  match 'members/set_full_names'
  match 'members/spouse_select'

  match 'families/:id/add_family_member' => 'families#add_family_member', :as => :add_family_member
  match 'members/edit_inline/:id' => 'members#edit_inline', :as => :edit_inline
   
 match 'reports/bloodtypes' => 'reports#bloodtypes'
match 'reports/birthdays' => 'reports#birthdays'
match 'reports/birthday_calendar' => 'reports#birthday_calendar'
match 'reports/tabletest' => 'reports#tabletest'
match 'reports/multi_col_test' => 'reports#multi_col_test'


#  resources :jqueries do as_routes end



#  devise_for :users
  resources :bloodtypes do as_routes end
  resources :cities do as_routes end
  resources :contact_types do as_routes end
  resources :contacts do as_routes end
  resources :countries do as_routes end
  resources :educations do as_routes end
  resources :employment_statuses do as_routes end
  resources :families do as_routes end
  resources :locations do as_routes end
  resources :members do as_routes end
  resources :ministries do as_routes end
  resources :states do as_routes end
  resources :statuses do as_routes end
  resources :field_terms do as_routes end
  resources :travels do as_routes end
  resources :users

  get "members/index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action
match 'admin/set_member_filter' => 'application#set_member_filter'

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
root :to => "members#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.

 #  match ':controller(/:action(/:id(.:format)))'
 #  match ':controller(/:action(.:format))'

  
end
