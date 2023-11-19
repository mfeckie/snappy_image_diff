defmodule SnappyImageDiffTest do
  use ExUnit.Case
  doctest SnappyImageDiff

  def fixture(filename) do
    path = "test/fixtures"

    {
      Path.join([path, "#{filename}a.png"]),
      Path.join([path, "#{filename}b.png"]),
      File.read!(Path.join([path, "#{filename}diff.png"]))
    }
  end

  test "Mismatched sizes" do
    before_image = "test/fixtures/6a.png"
    after_image = "test/fixtures/6a_cropped.png"

    assert {:error, :dimension_mismatch} = SnappyImageDiff.diff(before_image, after_image)
  end
end
