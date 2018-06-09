mix deps.get
mix ecto.create && mix ecto.migrate
mix phx.server
