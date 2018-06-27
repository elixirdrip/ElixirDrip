defmodule ElixirDripWeb.HealthController do
  @moduledoc false

  use ElixirDripWeb, :controller

  def health(conn, _params) do
    {_, timestamp} = Timex.format(DateTime.utc_now, "%FT%T%:z", :strftime)

    {:ok, hostname} = :inet.gethostname

    # Sleeping at most 13 seconds to see
    # the resulting histogram in Prometheus
    # (K8s health endpoint timeout is 15 seconds)
    sleep_millisecs = :rand.uniform(13_000)
    Process.sleep(sleep_millisecs)

    json(conn, %{
      ok: timestamp,
      hostname: to_string(hostname),
      node: Node.self(),
      connected_to: Node.list()
    })
  end
end
