defmodule SpritePacker.Core.Generator do
  @moduledoc """
    Contains all the core functions for generating spritesheets
  """

  require Logger

  @doc """
    Create image_blocks(an in-program image representation) from each image in the source directory
  """
  def create_image_blocks(source_dir) do
    case File.ls(source_dir) do
      {:ok, []} ->
        "No file in the directory"

      {:ok, files} ->
        filter_only_images(files)
        |> create_image_block_list(source_dir)

      {:error, _} ->
        "Error finding the source directory"
    end
  end

  @doc """
    Generate the spriteatlas from the given images

    Accepts size tuple, image_block_list
  """
  def generate_spriteatlas({{width, height}, block_list} = _atlas_info, dest_dir) do
    create_image_generation_command({width, height}, block_list, dest_dir)
    |> execute_command(dest_dir)
    |> generate_json_data({width, height}, block_list, dest_dir)
  end

  defp filter_only_images(files) do
    files
    |> Enum.filter(fn file ->
      file
      |> String.split(".")
      |> Enum.at(1)
      |> is_image()
    end)
  end

  defp is_image(file_extension) do
    file_extension in ["png", "jpeg", "jpg"]
  end

  defp create_image_block_list([], _source_dir), do: []

  defp create_image_block_list(files, source_dir) do
    files
    |> Enum.reduce([], fn file, block_list ->
      [extract_image_details_to_block(file, source_dir) | block_list]
    end)
  end

  defp extract_image_details_to_block(file, source_dir) do
    {size, _} = magick_exec(["identify", "-format", "%wx%h", "#{source_dir}/#{file}"])

    size_list =
      size
      |> String.split("x")
      |> Enum.map(fn size -> String.to_integer(size) end)

    block = %{x: 0, y: 0, w: nil, h: nil, can_fit: false, path: nil, name: nil}

    %{
      block
      | w: Enum.at(size_list, 0),
        h: Enum.at(size_list, 1),
        path: "#{source_dir}/#{file}",
        name: file |> String.split(".") |> Enum.at(0)
    }
  end

  defp create_image_generation_command({width, height}, block_list, dest_dir) do
    image_generation_command = [
      "convert -define png:exclude-chunks=date -quality 0% -size #{width}x#{height} xc:none"
    ]

    append_individual_image_operation_command(image_generation_command, block_list)
    |> append_command_endpart(dest_dir)
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

  defp append_command_endpart(image_generation_command, dest_dir) do
    ["#{dest_dir}/spriteatlas.png" | image_generation_command]
    |> Enum.reverse()
    |> Enum.join(" ")
  end

  defp execute_command(image_generation_command, dest_dir) do
    arg_list = String.split(image_generation_command)

    case create_dest_dir(dest_dir) do
      :ok -> magick_exec(arg_list)
      _ -> "Error when to tried to create destination folder"
    end
  end

  defp magick_exec(arg_list) do
    case :os.type() do
      {:win32, _} ->
        System.cmd("magick", arg_list)

      _ ->
        [exec_command | rest_arg_list] = arg_list
        System.cmd(exec_command, rest_arg_list)
    end
  end

  defp create_dest_dir(dest_dir) do
    case File.exists?(dest_dir) do
      true -> :ok
      false -> File.mkdir(dest_dir)
    end
  end

  defp generate_spriteatlas_json(block_list) do
    json_data = %{"frames" => %{}, "meta" => %{}}

    block_list
    |> Enum.reduce(json_data, fn block, json_data ->
      put_in(json_data["frames"][block.name], get_block_json(block))
    end)
  end

  defp get_block_json(block) do
    %{frame: %{x: block.x, y: block.y, w: block.w, h: block.h}}
  end

  defp append_json_data_meta(json_data, {width, height}, dest_dir) do
    Map.update!(json_data, "meta", fn _ ->
      %{
        app: "sprite_packer",
        version: "0.1.0",
        image: "spriteatlas.png",
        size: %{w: width, h: height}
      }
    end)
    |> Jason.encode!()
    |> save_json_data(dest_dir)
  end

  defp generate_json_data({"", 0}, {width, height}, block_list, dest_dir) do
    generate_spriteatlas_json(block_list)
    |> append_json_data_meta({width, height}, dest_dir)
  end

  defp generate_json_data(_, _, _, _) do
    :error
  end

  defp save_json_data(json_data, dest_dir) do
    File.write!("#{dest_dir}/spriteatlas.json", json_data)
    "Atlas and json created successfully in [#{dest_dir}] directory"
  end
end
