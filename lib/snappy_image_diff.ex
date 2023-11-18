defmodule SnappyImageDiff do
  use Rustler, otp_app: :snappy_image_diff, crate: :diff

  def diff(_arg1, _arg2), do: :erlang.nif_error(:nif_not_loaded)
end
