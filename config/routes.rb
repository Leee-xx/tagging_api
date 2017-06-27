Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post "tag", action: :add_tags, controller: "tags"
  get "tags/:entity_type/:entity_id/", to: 'tags#get_tags'
  delete "tags/:entity_type/:entity_id/", to: 'tags#delete'
  
  # Stats
  get "stats", to: 'tags#get_all_stats'
  get "stats/:entity_type/:entity_id/", to: 'tags#get_stats'
  
  #resources :tags do
    #get "tags/:entity_type/:entity_id/", action: :get_tags
    #get "tags/:entity_type/:entity_id/", to: 'tags#get_tags'
    #resources :entity
    # member do
      # get "tags/:entity_type/:entity_id/", action: :show
    # end
    #get "tags/:entity_type/:entity_id/", action: :show, controller: "tags"
  #end
  
  #resource :stats
end
