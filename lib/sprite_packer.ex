defmodule SpritePacker do
  @moduledoc """
    Contains the function that packs sprites into a single atlas
  """
  alias SpritePacker.Core.Generator
  alias SpritePacker.Algorithms.Sort
  alias SpritePacker.Algorithms.Packing.SimpleBinpack
  alias SpritePacker.Algorithms.Packing.GrowingBinpack

  def pack(
        source_dir \\ "test_sprites",
        dest_dir \\ "test_sprites/sprite_packer",
        algorithm \\ "growing",
        atlas_size \\ {1024, 768}
      ) do
    Generator.create_image_blocks(source_dir)
    |> Sort.sort_by_max()
    |> pack_by_algorithm(algorithm, atlas_size)
    |> filter_only_fit
    |> Generator.generate_spriteatlas(dest_dir)
    |> confirm_result(dest_dir)
  end

  defp pack_by_algorithm(block_list, algorithm_type, atlas_size)

  defp pack_by_algorithm(block_list, "simple", atlas_size),
    do: SimpleBinpack.pack(block_list, atlas_size)

  defp pack_by_algorithm(block_list, _, _), do: GrowingBinpack.pack(block_list)

  defp filter_only_fit({size, block_list}) do
    filtered_block_list =
      block_list
      |> Enum.filter(fn block ->
        block.can_fit === true
      end)

    {size, filtered_block_list}
  end

  defp confirm_result({"", 0}, dest_dir),
    do: "Atlas created successfully in [#{dest_dir}] directory"

  defp confirm_result(_, _), do: "Error occured"
end
