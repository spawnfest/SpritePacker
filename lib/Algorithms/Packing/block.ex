defmodule SpritePacker.Algorithms.Packing.Block do
  @moduledoc """
    Data structure for a block.
  """
  defstruct(
    x: 0,
    y: 0,
    w: nil,
    h: nil,
    can_fit: false
  )
end
