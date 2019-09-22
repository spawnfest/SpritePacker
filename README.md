# SpritePacker

SpritePacker is a command-line spritesheet (a.k.a. Texture Atlas) generator written in Elixir.

### Supported spritesheet formats ###
* JSON

### Usage ###
**Command Line**
```bash
$ escript .\sprite_packer -s .\test_sprites\
```
Options:
```bash
Note: Atlas and json data will be generated in "<source>/sprite_packer/"

Options:
    -s, [--src] # source directory of sprites to be packed into atlas
        --algorithm # algorithm to use for packing (default growing binpack algorithm)
        --size      # atlas size(only if using simple binpack algorithm), default 1024x768
    -h #help
```


### Installation ###
1. Install [ImageMagick](http://www.imagemagick.org/)
2. run mix escript.build (for building commandline application) from the project root.

### Test ###

1.  Build the Command-line application.
2.  run ```escript .\sprite_packer -s .\test_sprites\ ```
3.  A folder <sprite_packer> will be generated inside test_sprites(source_directory) with spriteatlas.png and spriteatlas.json

### Generated Atlas ###
![Generated spritesheet](temp/spriteatlas.png?raw=true "SpriteSheet")
