defmodule SpritePacker.Core.Generator do
  @moduledoc """
    Contains all the core functions for gnerating spritesheets
  """
  @source_dir "sprite_generator_source"
  require Logger
  def create_image_blocks() do
    case File.ls(@source_dir) do
      {:ok, files} ->
        filter_files_if_any(files) |>
        create_image_block_list()
      {:error, _} -> "Error finding the source directory"
    end
  end

  defp filter_files_if_any(files) do
    files |>
    Enum.filter(fn file ->
      file |> String.split(".") |> Enum.at(1) |> is_image()
    end)
  end

  defp is_image(file_extension) do
    file_extension in ["png", "jpeg", "jpg"]
  end

  defp create_image_block_list(files) do
    files |>
    Enum.reduce([], fn file, block_list ->
      [extract_image_details_to_block(file) | block_list]
    end)
  end

  defp extract_image_details_to_block(file) do
    {size, _} = System.cmd("magick", ["identify", "-format", "%wx%h", "#{@source_dir}/#{file}"])
    size_list = size |> String.split("x") |> Enum.map(fn size -> String.to_integer(size) end)
    block = %{x: 0, y: 0, w: nil, h: nil, can_fit: false, path: nil}
    %{
      block | w: Enum.at(size_list, 0),
              h: Enum.at(size_list, 1),
              path: "#{@source_dir}/#{file}"
    }
  end
end
