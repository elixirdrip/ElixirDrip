defmodule ElixirDrip.ReleaseTasks do
  @moduledoc """
  This module is an auxiliary module to run release tasks such as migrations.

  This module allows us to run migrations with the same release bundle we
  use to execute the application. Under `rel/commands` you will find the
  `migrate_up.sh` and `migrate_down.sh` shell scripts that respectively
  run the `migrate_up/0` and `migrate_down/0` functions on this module as
  a custom command declared in the Distillery release config file:

      release :elixir_drip do
        (...)
        set commands: [
          "migrate_up": "rel/commands/migrate_up.sh",
          "migrate_down": "rel/commands/migrate_down.sh"
        ]
      end
  """

  alias Ecto.Migrator

  @start_apps [:postgrex, :ecto]

  def migrate_up, do: migrate(:up)
  def migrate_down, do: migrate(:down)

  defp migrate(direction) do
    options = case direction do
      :up -> [all: true]
      :down -> [step: 1]
    end

    IO.puts("Loading ElixirDrip umbrella app...")
    :ok = Application.load(:elixir_drip)

    IO.puts("Starting dependencies...")
    Enum.each(@start_apps, &Application.ensure_all_started/1)

    IO.puts("Starting ElixirDrip repo...")
    ElixirDrip.Repo.start_link(pool_size: 1)

    IO.puts("Running migrations for ElixirDrip...")
    run_migrations(direction, options)

    IO.puts("Success!")
    :init.stop()
  end

  defp priv_dir(app), do: "#{:code.priv_dir(app)}"

  defp run_migrations(direction, options) do
    Migrator.run(ElixirDrip.Repo, migrations_path(:elixir_drip), direction, options)
  end

  defp migrations_path(app), do: Path.join([priv_dir(app), "repo", "migrations"])
end
