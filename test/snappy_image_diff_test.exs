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

  test "Images match" do
    before_image = "test/fixtures/1a.png"
    after_image = "test/fixtures/1a.png"

    assert {:ok, :images_match} = SnappyImageDiff.diff(before_image, after_image)
  end

  test "Mismatched sizes" do
    before_image = "test/fixtures/6a.png"
    after_image = "test/fixtures/6a_cropped.png"

    assert {:error, :dimension_mismatch} = SnappyImageDiff.diff(before_image, after_image)
  end

  test "Images do not match" do
    {before_image, after_image, diff_image} = fixture("2")

    assert {:error, :different, generated_diff} = SnappyImageDiff.diff(before_image, after_image)

    File.write!("test/fixtures/1-generated-diff.png", generated_diff)
  end
end
