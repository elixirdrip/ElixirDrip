defmodule ElixirDrip.Storage do
  @moduledoc false

  import Ecto.Query
  alias Ecto.Changeset
  alias ElixirDrip.Repo
  alias ElixirDrip.Storage.Workers.QueueWorker, as: Queue
  alias ElixirDrip.Storage.{
    Media,
    Owner,
    MediaOwners
  }

  @doc """
    It sequentially creates the Media on the DB and
    triggers an Upload request handled by the Upload Pipeline.
  """
  def store(user_id, file_name, full_path, content) do
    with %Owner{} = owner <- get_owner(user_id),
         %Changeset{} = changeset <- Media.create_initial_changeset(owner.id, file_name, full_path),
         %Changeset{} = changeset <- Changeset.put_assoc(changeset, :owners, [owner]),
         %Media{storage_key: _key} = media <- Repo.insert!(changeset)
    do
      upload_task = %{
        media: media,
        content: content,
        type: :upload
      }

      Queue.enqueue(Queue.Upload, upload_task)

      {:ok, :upload_enqueued, media}
    end
  end

  def set_upload_timestamp(%Media{} = media) do
    media
    |> Media.create_changeset(%{uploaded_at: DateTime.utc_now()})
    |> Repo.update!()
  end

  @doc """
    If the media belongs to the user,
    it triggers a Download request
    that will be handled by the Download Pipeline
  """
  def retrieve(user_id, media_id) do
    user_media = user_media_query(user_id)

    media_query = from [mo, m] in user_media,
      where: m.id == ^media_id,
      select: m

    case Repo.one(media_query) do
      nil   -> {:error, :not_found}
      media -> _retrieve(media)
    end
  end

  def media_by_folder(user_id, folder_path) do
    # TODO
  end

  def share(user_id, media_id, allowed_user_id) do
    with {:ok, :owner} <- is_owner?(user_id, media_id) do
      %MediaOwners{}
      |> Changeset.cast(%{user_id: allowed_user_id, media_id: media_id}, [:user_id, :media_id])
      |> Changeset.unique_constraint(:existing_share, name: :single_share_index)
      |> Repo.insert()
    else
      error -> error
    end
  end

  def delete(user_id, media_id) do
    with {:ok, :owner} <- is_owner?(user_id, media_id) do
    # TODO 1: delete all media_owner entries for media
    # TODO 2: delete media
    else
      error -> error
    end
  end

  def is_owner?(user_id, media_id) do
    (from m in Media,
      where: m.id == ^media_id,
      where: m.user_id == ^user_id)
      |> Repo.one()
      |> case do
        nil -> {:error, :not_owner}
        _ -> {:ok, :owner}
      end
  end

  def get_media(id), do: Repo.get!(Media, id)

  def get_owner(id, preloaded \\ false)
  def get_owner(id, false),
    do: Repo.get!(Owner, id)
  def get_owner(id, true),
    do: Repo.get!(Owner, id) |> Repo.preload(:files)

  def list_all_media do
    Media
    |> Repo.all()
  end

  def get_last_media do
    Repo.one(
      from media in Media,
      order_by: [desc: media.id],
      limit: 1
    )
  end

  defp user_media_query(user_id) do
    from media_owner in MediaOwners,
      join: media in Media,
      on: media_owner.media_id == media.id,
      where: media_owner.user_id == ^user_id
  end

  defp _retrieve(%Media{} = media) do
    download_task = %{
      media: media,
      type: :download
    }
    Queue.enqueue(Queue.Download, download_task)

    {:ok, :download_enqueued, media}
  end
end
