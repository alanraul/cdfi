defmodule CfdiWeb.Router do
  use CfdiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CfdiWeb do
    pipe_through :browser

    get "/", PageController, :index
    post "/", PageController, :xml
  end

  # Other scopes may use custom stacks.
  # scope "/api", CfdiWeb do
  #   pipe_through :api
  # end
end
