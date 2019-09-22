defmodule SortTest do
  use ExUnit.Case
  # alias SpritePacker.Algorithms.Packing.SimpleBinpack
  # alias SpritePacker.Algorithms.Packing.GrowingBinpack
  alias SpritePacker.Algorithms.Sort

  test "packing with simple binpack" do
    blocks = [
      %{x: 0, y: 0, w: 100, h: 100, can_fit: false},
      %{x: 0, y: 0, w: 30, h: 30, can_fit: false},
      %{x: 0, y: 0, w: 30, h: 30, can_fit: false},
      %{x: 0, y: 0, w: 100, h: 100, can_fit: false}
    ]

    assert Sort.sort_by_max(blocks) === [
             %{x: 0, y: 0, w: 100, h: 100, can_fit: false},
             %{x: 0, y: 0, w: 100, h: 100, can_fit: false},
             %{x: 0, y: 0, w: 30, h: 30, can_fit: false},
             %{x: 0, y: 0, w: 30, h: 30, can_fit: false}
           ]
  end
end
