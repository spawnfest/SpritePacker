defmodule SimpleBinpackTest do
  use ExUnit.Case
  alias SpritePacker.Algorithms.Packing.SimpleBinpack
  test "packing with simple binpack" do
    blocks = [%{x: 0, y: 0, w: 100, h: 100, can_fit: false}, %{x: 0, y: 0, w: 100, h: 100, can_fit: false},
    %{x: 0, y: 0, w: 30, h: 30, can_fit: false}, %{x: 0, y: 0, w: 30, h: 30, can_fit: false}]

    assert SimpleBinpack.pack(blocks) === []
  end
end
