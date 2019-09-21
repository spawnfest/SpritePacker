defmodule SpritePacker.Algorithms.Packing.SimpleBinpack do
  @moduledoc """
    A simple binary tree based binpack algorithm, that works on fixed atlas size.
  """

  def pack() do
    blocks = [%{x: 0, y: 0, w: 100, h: 100, can_fit: false}, %{x: 0, y: 0, w: 100, h: 100, can_fit: false},
    %{x: 0, y: 0, w: 30, h: 30, can_fit: false}, %{x: 0, y: 0, w: 30, h: 30, can_fit: false}]
    atlas_tree = create_init_tree()
    pack_the_blocks(blocks, atlas_tree, [])
  end

  defp pack_the_blocks([], atlas_tree, new_block_list), do: {atlas_tree, new_block_list}
  defp pack_the_blocks([h | t], atlas_tree, new_block_list) do
    atlas_node = find_atlasnode(h, Enum.fetch!(atlas_tree, 0), atlas_tree)
    atlas_tree = cond do
      atlas_node !== nil -> split_atlas_node(h, atlas_node, atlas_tree)
      true -> atlas_tree
    end
    pack_the_blocks(t, atlas_tree, [h] ++ new_block_list)
  end

  defp create_init_tree() do
    [%{id: 0, x: 0, y: 0, w: 500, h: 500, is_used: false}, nil, nil]
  end
  def find_atlasnode(block, %{is_used: true} = parent, atlas_tree) do
    find_atlasnode(block, Enum.fetch!(atlas_tree, (2 * parent.id) + 1), atlas_tree) ||
      find_atlasnode(block, Enum.fetch!(atlas_tree, (2 * parent.id) + 2), atlas_tree)
  end

  def find_atlasnode(%{w: b_w, h: b_h} = _block, %{w: node_w, h: node_h} = parent, atlas_tree)
       when b_w <= node_w and b_h <= node_h do
        Enum.fetch!(atlas_tree, parent.id)
  end

  def find_atlasnode(_, _), do: nil

  defp split_atlas_node(block, atlas_node, atlas_tree) do
    atlas_tree = List.update_at(atlas_tree, (2 * atlas_node.id) + 1, fn _ ->
      %{x: atlas_node.x + block.w, y: atlas_node.y, w: atlas_node.w - block.w, h: atlas_node.h, is_used: false, id: (2 * atlas_node.id) + 1}
    end)
    |> List.update_at((2 * atlas_node.id) + 2, fn _ ->
      %{x: atlas_node.x, y: atlas_node.y + block.h, w: atlas_node.w, h: atlas_node.h - block.h, is_used: false, id: (2 * atlas_node.id) + 2}
    end)
    |> List.update_at(atlas_node.id, fn node_info -> %{node_info | is_used: true} end)
    atlas_tree ++ [nil] ++ [nil] ++ [nil] ++ [nil]
  end
end
