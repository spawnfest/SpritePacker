defmodule SpritePacker.Algorithms.Packing.SimpleBinpack do
  @moduledoc """
    A simple Binary-Tree based binpack algorithm, that works on fixed atlas size.

    The whole Atlas is represented as a Binary Tree
  """
  require Logger

  def pack(blocks, {atlas_width, atlas_height} = _atlas_size) do
    create_atlas_tree(atlas_width, atlas_height)
    |> pack_the_blocks(blocks, [])
  end

  # A recursive function, that loops through each block and find a fit in the atlas.
  # Returns a {size, new_image_block_list}

  defp pack_the_blocks(atlas_tree, [], new_block_list) do
    root_node = Enum.at(atlas_tree, 0)
    {{root_node.w, root_node.h}, new_block_list}
  end

  defp pack_the_blocks(atlas_tree, [h | t], new_block_list) do
    # Logger.info(inspect atlas_tree)

    # Starting from the root node.
    atlas_node = find_atlasnode(h, Enum.fetch!(atlas_tree, 0), atlas_tree)
    # Logger.info(inspect atlas_node)
    {updated_block, atlas_tree} =
      cond do
        atlas_node !== nil ->
          {update_block(h, atlas_node), split_atlas_node(h, atlas_node, atlas_tree)}

        true ->
          {h, atlas_tree}
      end

    pack_the_blocks(atlas_tree, t, [updated_block] ++ new_block_list)
  end

  defp create_atlas_tree(atlas_width, atlas_height) do
    [%{id: 0, x: 0, y: 0, w: atlas_width, h: atlas_height, is_used: false}, nil, nil]
  end

  defp find_atlasnode(block, %{is_used: true} = parent, atlas_tree) do
    Logger.info(
      "tree count => #{inspect(Enum.count(atlas_tree))}, fetch => #{inspect(2 * parent.id + 2)}"
    )

    find_atlasnode(block, Enum.at(atlas_tree, 2 * parent.id + 1), atlas_tree) ||
      find_atlasnode(block, Enum.at(atlas_tree, 2 * parent.id + 2), atlas_tree)
  end

  defp find_atlasnode(%{w: b_w, h: b_h} = _block, %{w: node_w, h: node_h} = parent, atlas_tree)
       when b_w <= node_w and b_h <= node_h do
    Enum.fetch!(atlas_tree, parent.id)
  end

  defp find_atlasnode(_, _, _), do: nil

  defp split_atlas_node(block, atlas_node, atlas_tree) do
    atlas_tree =
      List.update_at(atlas_tree, 2 * atlas_node.id + 1, fn _ ->
        %{
          x: atlas_node.x + block.w,
          y: atlas_node.y,
          w: atlas_node.w - block.w,
          h: atlas_node.h,
          is_used: false,
          id: 2 * atlas_node.id + 1
        }
      end)
      |> List.update_at(2 * atlas_node.id + 2, fn _ ->
        %{
          x: atlas_node.x,
          y: atlas_node.y + block.h,
          w: atlas_node.w,
          h: atlas_node.h - block.h,
          is_used: false,
          id: 2 * atlas_node.id + 2
        }
      end)
      |> List.update_at(atlas_node.id, fn node_info -> %{node_info | is_used: true} end)

    atlas_tree ++ [nil] ++ [nil] ++ [nil] ++ [nil]
  end

  defp update_block(block, atlas_node) do
    %{
      block
      | x: atlas_node.x,
        y: atlas_node.y,
        can_fit: true
    }
  end
end
