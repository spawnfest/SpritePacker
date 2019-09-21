defmodule SpritePacker.Algorithms.Packing.AtlasNode do
  @moduledoc """
    Data structure for atlasNode
  """

  defstruct(
    x: 0,
    y: 0,
    w: nil,
    h: nil,
    right: nil,
    down: nil,
    is_used: false
  )
end
