# SnappyImageDiff

Elixir wrapper for [image-compare](https://github.com/ChrisRega/image-compare).

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `snappy_image_diff` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:snappy_image_diff, "~> 0.1.0"}
  ]
end
```

## Usage

Provide SnappyImageDiff with two files to compare and an output destination for any diff

```elixir
SnappyImageDiff.compare("image1.png", "image2.png", "some_directory/diff.png")
```

For more detail, see the docs.

## Publishing

After CI has completed and the binaries have been compiled, download them and generate checksum

`mix rustler_precompiled.download SnappyImageDiff --all --print`

Then publish to Hex

`mix hex.publish`

## License

SnappyImageDiff is released under the MIT License. See the LICENSE file for further
details.
