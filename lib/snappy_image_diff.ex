defmodule SnappyImageDiff do
  use Rustler, otp_app: :snappy_image_diff, crate: :diff

  def diff(before_path, after_path) do
    expanded = Path.expand(before_path)
    filename = Path.basename(expanded, ".png")
    directory = Path.dirname(expanded)

    output_path = Path.join([directory, "#{filename}-diff"])

    diff(before_path, after_path, output_path)
  end

  def diff(_before, _after, _output_path), do: :erlang.nif_error(:nif_not_loaded)
end
