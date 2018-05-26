defmodule ElixirDripWeb.HealthController do
  @moduledoc false

  use ElixirDripWeb, :controller

  def health(conn, _params) do
    {_, timestamp} = Timex.format(DateTime.utc_now, "%FT%T%:z", :strftime)

    {:ok, hostname} = :inet.gethostname

    json(conn, %{
      ok: timestamp,
      hostname: to_string(hostname),
      node: Node.self(),
      connected_to: Node.list()
    })
  end
end
