defmodule ElixirDrip.Config.GcsCredentials do
  use Goth.Config

  def init(config) do
    {:ok, Keyword.put(config, :json, google_cloud_storage_creds())}
  end

  defp google_cloud_storage_creds() do
    "GOOGLE_STORAGE_CREDENTIALS"
    |> System.get_env()
    |> Base.decode64!()
  end
end
