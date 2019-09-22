defmodule SpritePacker.CLI do
  require Logger

  def main(args) do
    args
    |> parse_options
    |> process_options
  end

  defp parse_options(args) do
    OptionParser.parse(args,
      switches: [src: :string, algorithm: :string, size: :string],
      aliases: [s: :src]
    )
  end

  def process_options(options) do
    # Logger.info(inspect options)
    case options do
      {[_h | _t] = args, _, _} -> prepare_for_packing(args)
      _ -> display_help()
    end
  end

  defp display_help() do
    IO.puts("""

    Usage:

    sprite_packer -s [source directory] [options]

    Note: Atlas will be generated in "source/sprite_packer/"

    Options:
    -s, [--src] # source directory of sprites to be packed into atlas
        --algorithm # algorithm to use for packing (default growing binpack algorithm)
        --size      # atlas size(only if using simple binpack algorithm), default 1024x768
    -h #help
    Example:
    ./sprite_packer -s ./sprite_source

    """)

    System.halt(0)
  end

  defp prepare_for_packing([src: source] = _arg_list) do
    SpritePacker.pack(source, "#{source}/sprite_packer")
  end

  defp prepare_for_packing(src: source, algorithm: algo, size: atlas_size) do
    SpritePacker.pack(source, "#{source}/sprite_packer", algo, atlas_size)
  end

  defp prepare_for_packing(_), do: display_help()
end
