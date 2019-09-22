defmodule SpritePacker.Core.Generator do
  @moduledoc """
    Contains all the core functions for gnerating spritesheets
  """
  @source_dir "sprite_generator_source"
  @dest_dir "sprite_generator_dest"

  require Logger

  @doc """
    Create image_blocks(an in-program image representation) from each image in the source directory
  """
  def create_image_blocks() do
    case File.ls(@source_dir) do
      {:ok, files} ->
        filter_files_if_any(files)
        |> create_image_block_list()

      {:error, _} ->
        "Error finding the source directory"
    end
  end

  @doc """
    Generate the spriteatlas from the given images

    Accepts size tuple, image_block_list
  """
  def generate_spriteatlas({width, height}, block_list) do
    create_image_generation_command({width, height}, block_list)
    |> execute_command()
  end

  defp filter_files_if_any(files) do
    files
    |> Enum.filter(fn file ->
      file |> String.split(".") |> Enum.at(1) |> is_image()
    end)
  end

  defp is_image(file_extension) do
    file_extension in ["png", "jpeg", "jpg"]
  end

  defp create_image_block_list(files) do
    files
    |> Enum.reduce([], fn file, block_list ->
      [extract_image_details_to_block(file) | block_list]
    end)
  end

  defp extract_image_details_to_block(file) do
    {size, _} = System.cmd("magick", ["identify", "-format", "%wx%h", "#{@source_dir}/#{file}"])
    size_list = size |> String.split("x") |> Enum.map(fn size -> String.to_integer(size) end)
    block = %{x: 0, y: 0, w: nil, h: nil, can_fit: false, path: nil}

    %{
      block
      | w: Enum.at(size_list, 0),
        h: Enum.at(size_list, 1),
        path: "#{@source_dir}/#{file}"
    }
  end

  defp create_image_generation_command({width, height}, block_list) do
    image_generation_command = [
      "convert -define png:exclude-chunks=date -quality 0% -size #{width}x#{height} xc:none"
    ]

    append_individual_image_operation_command(image_generation_command, block_list)
    |> append_command_endpart()
  end

  defp append_individual_image_operation_command(image_generation_command, block_list) do
    block_list
    |> Enum.reduce(image_generation_command, fn image_block, image_generation_command ->
      [get_image_composite_command(image_block) | image_generation_command]
    end)
  end

  defp get_image_composite_command(%{path: path, x: x, y: y} = _image_block) do
    ["#{path} -geometry +#{x}+#{y} -composite"]
  end

  defp append_command_endpart(image_generation_command) do
    ["#{@dest_dir}/spriteatlas.png" | image_generation_command]
    |> Enum.reverse()
    |> Enum.join(" ")
  end

  defp execute_command(image_generation_command) do
    arg_list = String.split(image_generation_command)
    System.cmd("magick", arg_list)
  end
end
