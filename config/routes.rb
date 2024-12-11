Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "/doacoes", to: "doacoes#index"
  post "/doacoes", to: "doacoes#marca_doacao"
  post "/usuarios", to: "usuarios#cria_usuario"
  get "/doacoes/usuario", to: "doacoes#por_usuario"
  get "/usuarios", to: "usuarios#index"
  delete "/doacoes", to: "doacoes#deleta_agendamento"
  put "/doacoes", to: "doacoes#modifica_agendamento"
  # Defines the root path route ("/")
  # root "posts#index"
end
