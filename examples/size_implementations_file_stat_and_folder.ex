defimpl Size, for: File.Stat do
  def size(file_stat), do: file_stat.size
end

defimpl Size, for: Folder do
  def size(folder) do
    folder.files_info
    |> Enum.map(&Size.size(&1))
    |> Enum.sum()
  end
end
