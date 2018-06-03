defmodule ElixirDripWeb.Router do
  use ElixirDripWeb, :router

  alias ElixirDripWeb.Plugs.FetchUser

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
    plug(FetchUser)
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

    resources("/files", FileController, only: [:index, :new, :create, :show])
    get("/files/:id/download", FileController, :download)
    post("/files/:id/download", FileController, :enqueue_download)

    resources("/users", UserController, only: [:new, :create])

    resources("/sessions", SessionController, only: [:new, :create])
    delete("/sessions", SessionController, :delete)

    get("/", PageController, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", ElixirDripWeb do
  #   pipe_through :api
  # end
end
