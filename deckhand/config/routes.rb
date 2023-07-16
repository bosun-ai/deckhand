Rails.application.routes.draw do
  resources :autonomous_assignments
  resources :tasks

  resources :codebases do
    post 'discover_testing_infrastructure', to: 'codebases#discover_testing_infrastructure', as: :discover_testing_infrastructure
  end

  root "main_deck#show", as: :main_deck

  namespace "github_app" do
    get 'callback', to: 'github_app#github_app_callback', as: :callback
    get 'setup', to: 'github_app#github_app_setup', as: :setup
    post 'event', to: 'github_app#github_app_event', as: :event   
  end
end
