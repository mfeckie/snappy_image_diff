defmodule SnappyImageDiff do
  use Rustler, otp_app: :snappy_image_diff, crate: :diff

  def diff(_before, _after), do: :erlang.nif_error(:nif_not_loaded)

  def diff_and_save(_before, _after, _output_path), do: :erlang.nif_error(:nif_not_loaded)
end
