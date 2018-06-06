use Mix.Config

config :elixir_drip, ElixirDrip.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "${DB_USER}",
  password: "${DB_PASS}",
  database: "${DB_NAME}",
  hostname: "${DB_HOST}",
  port: "${DB_PORT}",
  pool_size: 15

config :elixir_drip,
  storage_provider: ElixirDrip.Storage.Providers.GoogleCloudStorage.Live

config :libcluster,
  topologies: [
    elixir_drip_topology: [
      strategy: Cluster.Strategy.Kubernetes,
      config: [
        kubernetes_selector: "app=elixir-drip,env=production",
        kubernetes_node_basename: "elixir_drip"]]]
