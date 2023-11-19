defmodule SnappyImageDiff do
  mix_config = Mix.Project.config()
  version = mix_config[:version]

  use RustlerPrecompiled,
    otp_app: :snappy_image_diff,
    crate: :snappy_image_diff,
    version: version,
    base_url: "https://github.com/mfeckie/snappy_image_diff/releases/download/#{version}",
    force_build: System.get_env("FORCE_COMPILE") in ["1", "true"],
    targets: ~w(
      aarch64-apple-darwin
      aarch64-unknown-linux-gnu
      aarch64-unknown-linux-musl
      riscv64gc-unknown-linux-gnu
      x86_64-apple-darwin
      x86_64-pc-windows-msvc
      x86_64-pc-windows-gnu
      x86_64-unknown-linux-gnu
      x86_64-unknown-linux-musl
    )

  @doc """
  Compare two images and return a tuple with the result.

  And differences will be written to a file in the same directory as the
  `before` image with the suffix `-diff`.
  """
  def diff(before_path, after_path) do
    expanded = Path.expand(before_path)
    filename = Path.basename(expanded, ".png")
    directory = Path.dirname(expanded)

    output_path = Path.join([directory, "#{filename}-diff"])

    diff(before_path, after_path, output_path)
  end

  @doc """
  Compare two images and return a tuple with the result.

  And differences will be written to the path specified by `output_path`.

  Returns `{:ok, :images_match}` if the images are identical.
  Returns `{:error, :dimension_mismatch}` if the images are different sizes.
  Returns `{:error, :different, score, diff_location}` if the images are different.

  ## Examples

      iex> SnappyImageDiff.diff("test/fixtures/1a.png", "test/fixtures/1a.png", "some_destination.png")
      {:ok, :images_match}

      iex> SnappyImageDiff.diff("test/fixtures/6a.png", "test/fixtures/6a_cropped.png", "some_destination.png")
      {:error, :dimension_mismatch}

      iex> SnappyImageDiff.diff("test/fixtures/1a.png", "test/fixtures/1b.png", "test/fixtures/1a-diff")
      {:error, :different, 0.9833533452322089, "test/fixtures/1a-diff.png"}
  """
  def diff(_before, _after, _output_path), do: :erlang.nif_error(:nif_not_loaded)
end
