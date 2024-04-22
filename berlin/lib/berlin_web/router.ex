defmodule BerlinWeb.Router do
  use BerlinWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug Guardian.Plug.Pipeline, module: Berlin.Guardian, error_handler: Berlin.Guardian.AuthErrorHandler
    plug Guardian.Plug.VerifyHeader
    plug Guardian.Plug.EnsureAuthenticated
    plug Berlin.Guardian.CurrentUser
  end

  scope "/", BerlinWeb do
    pipe_through :api

    resources "/sessions", SessionController, only: [:create, :delete]
    resources "/registrations", RegistrationController, only: [:create]
  end

  scope "/", BerlinWeb do
    pipe_through [:api, :authenticated]

    resources "/users", UserController, only: [:create, :index]
  end

  scope "/private", BerlinWeb do
    pipe_through :api

    get "/jwks.json", JWKController, :jwk
  end
end
