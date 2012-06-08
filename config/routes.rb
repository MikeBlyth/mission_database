SIM::Application.routes.draw do


  resources :messages do as_routes end

# SMS with Twilio

  resources :sms

  resources :sessions, :only => [:new, :create, :destroy]
  get "sessions/new"

#  match '/signup',  :to => 'users#new'
  match '/signin',  :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'

# These are "forbidden" routes that would only be requested by someone trying to hack
  match "health_data", :method=>'post', :to => "sessions#destroy"
  match "health_data/new", :to => "sessions#destroy"
  match "health_data/:id", :to => "sessions#destroy"
  match "health_data/:id/edit", :to => "sessions#destroy"
  match "personnel_data", :method=>'post', :to => "sessions#destroy"
  match "personnel_data/new", :to => "sessions#destroy"
  match "personnel_data/:id", :to => "sessions#destroy"
  match "personnel_data/:id/edit", :to => "sessions#destroy"


  match 'countries_autocomplete/index'
  match '*a/autocomplete/country' => 'autocomplete#country'
  match 'autocomplete/country' 
  match 'autocomplete/family'
  match 'autocomplete/spouse'
  match 'autocomplete_searches/index'
  match 'members/set_full_names'
  match 'members/spouse_select'
  match 'families/:id/add_family_member' => 'families#add_family_member', :as => :add_family_member
  match 'members/edit_inline/:id' => 'members#edit_inline', :as => :edit_inline

  match ':controller/export', :action => 'export'
   
  match 'reports/bloodtypes' => 'reports#bloodtypes', :defaults => {:format => 'pdf'}, :as => 'bloodtype_report'
  match 'reports/birthdays' => 'reports#birthdays', :as => 'birthday_report'
  match 'reports/calendar' => 'reports#calendar', :as => 'calendar_report'
  match 'reports/birthday_calendar' => 'reports#birthday_calendar', :as => 'birthday_calendar_report'
  get 'reports/status_mismatch' => 'reports#status_mismatch', :as => 'status_mismatch_report'
  put 'reports/status_mismatch' => 'members#update_statuses', :as => 'members_update_statuses'
  match 'reports/travel_calendar' => 'reports#travel_calendar', :as => 'travel_calendar_report'
  match 'reports/birthday_travel_calendar' => 'reports#birthday_travel_calendar', :as => 'birthday_travel_calendar_report'
  match 'reports/whereis' => 'reports#whereis', :as => 'whereis_report'
  get  'reports/contact_updates' => 'reports#contact_updates', :as => 'contact_updates'
  put 'reports/contact_updates' => 'reports#send_contact_updates', :as => 'send_contact_updates'
  match 'reports/index' => 'reports#index', :as => 'reports'
  match 'members/list_field_terms' => 'members#list_field_terms', :as=> :list_field_terms
  match 'reports/:action(.:format)' => 'reports#:action'
#  match 'reports/tabletest' => 'reports#tabletest'
#  match 'reports/multi_col_test' => 'reports#multi_col_test'

  match 'admin/clean_database' => 'admin#clean_database', :as => 'clean_database'
  get 'admin/travel_updates' => 'admin#review_travel_updates', :as => 'travel_updates'
  put 'admin/travel_updates' => 'admin#send_travel_updates', :as => 'send_travel_updates'
  get   'admin/family_summaries' => 'admin#review_family_summaries', :as => 'family_summaries'
  post  'admin/family_summaries' => 'admin#send_family_summaries', :as => 'send_family_summaries'
  get   'admin/travel_reminders' => 'admin#review_travel_reminders', :as => 'travel_reminders'
  post  'admin/travel_reminders' => 'admin#send_travel_reminders', :as => 'send_travel_reminders'

   get   'admin/site_settings' => 'site_settings#edit', :as=>'site_settings'
   get   'admin/site_settings/index' => 'site_settings#index', :as=>'index_site_settings'
   put  'admin/site_settings' => 'site_settings#update', :as=>'update_site_settings'
  

#  resources :jqueries do as_routes end
#  resources :site_settings do as_routes end

  resources :app_logs do as_routes end
  resources :bloodtypes do as_routes end
  resources :incoming_mails do as_routes end
  resources :calendar_events do as_routes end
  resources :cities do as_routes end
  resources :contact_types do as_routes end
  resources :contacts do as_routes end
  resources :countries do as_routes end
  resources :educations do as_routes end
  resources :employment_statuses do as_routes end
  resources :families do as_routes end
  resources :field_terms do as_routes end
#  resources :health_data do as_routes end
  resources :groups do as_routes end
  resources :locations do as_routes end
  resources :members do as_routes end
  resources :ministries do as_routes end
#  resources :personnel_data do as_routes end
  resources :pers_tasks do as_routes end
  resources :states do as_routes end
  resources :statuses do as_routes end
  resources :travels do as_routes end
  resources :users do
    member do
      get 'edit_roles'
      put 'update_roles'
    end
  end

  
  
  get "members/index"

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action
match 'application/set_member_filter' => 'application#set_member_filter', :as=>'set_member_filter'
match 'application/set_travel_filter' => 'application#set_travel_filter', :as=>'set_travel_filter'

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
