Rails.application.routes.draw do
  resources :autonomous_assignments
  resources :tasks
  resources :codebases do
    post 'discover_testing_infrastructure', to: 'codebases#discover_testing_infrastructure', as: :discover_testing_infrastructure
  end

  root "main_deck#show", as: :main_deck
end
