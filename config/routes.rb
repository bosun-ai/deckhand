Rails.application.routes.draw do
  mount GoodJob::Engine => 'good_job'

  resources :codebase_agent_services

  resources :agent_runs do
    post "retry", to: "agent_runs#retry", as: :retry
  end

  resources :agent_run_events do
    get "expanded", to: "agent_run_events#expanded", as: :expand
  end

  resources :shell_tasks

  resources :codebases do
    post 'discover_testing_infrastructure', to: 'codebases#discover_testing_infrastructure',
                                            as: :discover_testing_infrastructure
  end

  root 'main_deck#show', as: :main_deck

  resource 'github_app', only: [] do
    get 'callback', to: 'github_app#callback', as: :callback
    get 'setup', to: 'github_app#setup', as: :setup
    post 'event', to: 'github_app#event', as: :event
  end
end
