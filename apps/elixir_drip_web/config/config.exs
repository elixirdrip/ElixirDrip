# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :elixir_drip_web,
  namespace: ElixirDripWeb,
  ecto_repos: [ElixirDrip.Repo]

# Configures the endpoint
config :elixir_drip_web, ElixirDripWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: ElixirDripWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ElixirDripWeb.PubSub, adapter: Phoenix.PubSub.PG2],
  instrumenters: [ElixirDripWeb.EndpointInstrumenter]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :prometheus, ElixirDripWeb.PlugInstrumenter,
  labels: [:status_class, :method, :host, :scheme, :request_path]

import_config "#{Mix.env()}.exs"
