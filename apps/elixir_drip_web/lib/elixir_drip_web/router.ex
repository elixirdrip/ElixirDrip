defmodule ElixirDripWeb.Router do
  use ElixirDripWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  pipeline :logger do
    plug(Plug.Logger)
  end

  get("/health", ElixirDripWeb.HealthController, :health)

  scope "/", ElixirDripWeb do
    pipe_through([:browser, :logger])

    get("/", PageController, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", ElixirDripWeb do
  #   pipe_through :api
  # end
end
