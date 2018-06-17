defmodule ElixirDrip.Storage.MediaTest do
  use ExUnit.Case, async: true

  @subject ElixirDrip.Storage.Media

  test "is_valid_path?/1 returns {:ok, :valid} for a valid path" do
    path = "$/abc"

    assert {:ok, :valid} == @subject.is_valid_path?(path)
  end
end
