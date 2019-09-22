defmodule SpritePacker.Algorithms.Packing.GrowingBinpack do
  @moduledoc """
     A Binary-Tree based binpack algorithm, where atlas size grows according to the new block size.

  """
  require Logger

  def pack(blocks) do
    # Pass the largest block to initialize the width and height of atlas tree
    create_atlas_tree(Enum.fetch!(blocks, 0))
    |> pack_the_blocks(blocks, [])
  end

  # A recursive function, that loops through each block and find a fit in the atlas.
  defp pack_the_blocks(atlas_tree, [], new_block_list),
    do: {Enum.at(atlas_tree, 0), new_block_list}

  defp pack_the_blocks(atlas_tree, [h | t], new_block_list) do
    # Starting from the root node.
    atlas_node = find_atlasnode(h, Enum.fetch!(atlas_tree, 0), atlas_tree)
    Logger.info(inspect(atlas_node))

    {updated_block, atlas_tree} =
      cond do
        atlas_node !== nil ->
          {update_block(h, atlas_node), split_atlas_node(h, atlas_node, atlas_tree)}

        true ->
          grow_atlasnode(h, atlas_tree)
      end

    pack_the_blocks(atlas_tree, t, [updated_block] ++ new_block_list)
  end

  defp create_atlas_tree(%{w: width, h: height} = _largest_block) do
    [%{id: 0, x: 0, y: 0, w: width, h: height, is_used: false}, nil, nil]
  end

  defp find_atlasnode(block, %{is_used: true} = parent, atlas_tree) do
    find_atlasnode(block, Enum.fetch!(atlas_tree, 2 * parent.id + 1), atlas_tree) ||
      find_atlasnode(block, Enum.fetch!(atlas_tree, 2 * parent.id + 2), atlas_tree)
  end

  defp find_atlasnode(%{w: b_w, h: b_h} = _block, %{w: node_w, h: node_h} = parent, atlas_tree)
       when b_w <= node_w and b_h <= node_h do
    Enum.fetch!(atlas_tree, parent.id)
  end

  defp find_atlasnode(_, _, _), do: nil

  # Have to Refactor and optimize this function, must
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

  defp grow_atlasnode(block, atlas_tree) do
    root_node = Enum.fetch!(atlas_tree, 0)
    can_grow_right = block.h <= root_node.h
    can_grow_down = block.w <= root_node.w

    should_grow_right = can_grow_right and root_node.h >= root_node.w + block.w
    should_grow_down = can_grow_down and root_node.w >= root_node.h + block.h

    cond do
      should_grow_right -> grow_right(block, atlas_tree)
      should_grow_down -> grow_down(block, atlas_tree)
      can_grow_right -> grow_right(block, atlas_tree)
      can_grow_down -> grow_down(block, atlas_tree)
      true -> nil
    end
  end

  defp grow_right(block, atlas_tree) do
    # Update the root node., have to update
    root_node = Enum.fetch!(atlas_tree, 0)

    List.update_at(atlas_tree, 1, fn node_info ->
      %{node_info | x: root_node.w, y: 0, w: block.w, h: root_node.h, is_used: false}
    end)

    atlas_tree =
      List.update_at(atlas_tree, 0, fn node_info ->
        %{node_info | w: node_info.w + block.w}
      end)

    atlas_node = find_atlasnode(block, Enum.fetch!(atlas_tree, 0), atlas_tree)

    cond do
      atlas_node !== nil ->
        {update_block(block, atlas_node), split_atlas_node(block, atlas_node, atlas_tree)}

      true ->
        {block, atlas_tree}
    end
  end

  defp grow_down(block, atlas_tree) do
    root_node = Enum.fetch!(atlas_tree, 0)

    List.update_at(atlas_tree, 2, fn node_info ->
      %{node_info | x: 0, y: root_node.h, w: root_node.w, h: block.h, is_used: false}
    end)

    List.update_at(atlas_tree, 0, fn node_info ->
      %{node_info | h: node_info.h + block.h}
    end)

    atlas_node = find_atlasnode(block, Enum.fetch!(atlas_tree, 0), atlas_tree)

    cond do
      atlas_node !== nil ->
        {update_block(block, atlas_node), split_atlas_node(block, atlas_node, atlas_tree)}

      true ->
        {block, atlas_tree}
    end
  end
end
