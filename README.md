# SpritePacker

SpritePacker is a command-line spritesheet (a.k.a. Texture Atlas) generator written in Elixir.

### Supported spritesheet formats ###
* JSON

### Usage ###
**Command Line**
```bash
$ escript sprite_packer -s test_sprites
```
Options:
```bash
$ sprite_packer
Usage: sprite_packer -s [source directory] [options]

Note: Atlas will be generated in "<source>/sprite_packer/"

Options:
    -s, [--src] # source directory of sprites to be packed into atlas
        --algorithm # algorithm to use for packing (default growing binpack algorithm)
        --size      # atlas size(only if using simple binpack algorithm), default 1024x768
    -h #help
```


### Installation ###
1. Install [ImageMagick](http://www.imagemagick.org/)
2. mix escript.build (for building commandline)

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `sprite_packer` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:sprite_packer, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/sprite_packer](https://hexdocs.pm/sprite_packer).

