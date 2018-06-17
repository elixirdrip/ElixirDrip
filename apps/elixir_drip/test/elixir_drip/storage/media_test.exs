defmodule ElixirDrip.Storage.MediaTest do
  use ExUnit.Case, async: true

  @subject ElixirDrip.Storage.Media

  setup do
    user_id = "0ujsswThIGTUYm2K8FjOOfXtY1K"
    file_name = "test.txt"
    full_path = "$/abc"
    file_size = 123

    {:ok, user_id: user_id, file_name: file_name, full_path: full_path, file_size: file_size}
  end

  test "create_initial_changeset/4 returns a valid changeset", context do
    changeset = @subject.create_initial_changeset(context.user_id, context.file_name, context.full_path, context.file_size)

    assert changeset.valid? == true
  end

  test "is_valid_path?/1 returns {:ok, :valid} for a valid path" do
    path = "$/abc"

    assert {:ok, :valid} == @subject.is_valid_path?(path)
  end

  test "is_valid_path?/1 returns {:error, :invalid_path} for an invalid path" do
    path = "$/abc/"

    assert {:error, :invalid_path} == @subject.is_valid_path?(path)
  end
end
