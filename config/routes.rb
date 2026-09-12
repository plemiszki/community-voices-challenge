Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root to: "application#root"

  namespace :api, defaults: { format: :json } do
    get "ingestion", to: "ingestions#show"
    post "ingestion", to: "ingestions#create"
    post "community_voices_document", to: "community_voices_documents#create"
    get "embeddings/visualization", to: "embeddings#visualization"
    get "retrieval_stats", to: "retrieval_stats#index"
  end
end
