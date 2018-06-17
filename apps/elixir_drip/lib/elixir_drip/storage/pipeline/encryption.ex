defmodule ElixirDrip.Storage.Pipeline.Encryption do
  @moduledoc false
  @dummy_state []

  require Logger
  alias   ElixirDrip.Storage.Providers.Encryption.Simple, as: Provider
  alias   ElixirDrip.Storage.Supervisors.CacheSupervisor, as: Cache

  use ElixirDrip.Pipeliner.Consumer, type: :producer_consumer

  @impl ElixirDrip.Pipeliner.Consumer
  def prepare_state([]) do
    Logger.debug("#{inspect(self())}: Streamlined Pipeline Encryption started.")

    @dummy_state
  end

  @impl GenStage
  def handle_events(tasks, _from, _state) do
    encrypted = Enum.map(tasks, &encryption_step(&1))

    {:noreply, encrypted, @dummy_state}
  end

  defp encryption_step(%{media: %{id: id, encryption_key: encryption_key}, content: content, type: :upload} = task) do
    Process.sleep(1000)

    Cache.put(id, content)
    Logger.info("#{inspect(self())}: Placed media #{id} in cache, size: #{byte_size(content)} bytes.")

    Logger.debug("#{inspect(self())}: Encrypting media #{id}, size: #{byte_size(content)} bytes.")

    %{task | content: Provider.encrypt(content, encryption_key)}
  end

  defp encryption_step(%{media: media, content: _content, status: :original, type: :download} = task) do
    Logger.debug("#{inspect(self())}: Media #{media.id} already decrypted, skipping decryption...")

    task
  end

  defp encryption_step(%{media: %{id: id, encryption_key: encryption_key}, content: content, type: :download} = task) do
    Process.sleep(1000)
    Logger.debug("#{inspect(self())}: Decrypting media #{id}, size: #{byte_size(content)} bytes.")

    clear_content = Provider.decrypt(content, encryption_key)
    Cache.put_or_refresh(id, clear_content)

    %{task | content: clear_content}
  end
end

