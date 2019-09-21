defmodule SpritePacker.Algorithms.Sort do
  @moduledoc """
    Sorts the blocks by max(width, height)
  """

  def sort_by_max(blocks) do
    blocks
    |> Enum.sort(&compare_by_max/2)
  end

  defp compare_by_max(block1, block2) do
    max(block1.w, block1.h) >= max(block2.w, block2.h)
  end
end
