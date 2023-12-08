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

  test "Baseline image missing" do
    before_image = "test/fixtures/not_found.png"
    after_image = "test/fixtures/1b.png"

    assert {:error, :baseline_image_not_found} =
             SnappyImageDiff.diff(before_image, after_image)
  end

  test "Comparison image missing" do
    before_image = "test/fixtures/1a.png"
    after_image = "test/fixtures/not_found.png"

    assert {:error, :comparison_image_not_found} =
             SnappyImageDiff.diff(before_image, after_image)
  end

  test "Mismatched sizes" do
    before_image = "test/fixtures/6a.png"
    after_image = "test/fixtures/6a_cropped.png"

    assert {:error, :dimension_mismatch} =
             SnappyImageDiff.diff(before_image, after_image)
  end

  test "Images do not match" do
    for n <- 1..7 do
      {before_image, after_image, diff_image} = fixture(n)

      assert {:error, :different, _score, diff_location} =
               SnappyImageDiff.diff(before_image, after_image)

      assert diff_image == File.read!(diff_location)
    end
  end

  describe "Scoring only" do
    test "Images match" do
      before_image = "test/fixtures/1a.png"
      after_image = "test/fixtures/1a.png"

      assert {:ok, :images_match} =
               SnappyImageDiff.diff(before_image, after_image)
    end

    test "Images do not match" do
      for n <- 1..7 do
        {before_image, after_image, _diff_image} = fixture(n)

        assert {:error, :different, score, _diff_location} =
                 SnappyImageDiff.diff(before_image, after_image)

        assert score < 1.0
      end
    end

    test "Scores no matching images" do
      before_image = "test/fixtures/1a.png"
      after_image = "test/fixtures/1b.png"

      assert {:error, :different, 0.9833533452322089, _diff_location} =
               SnappyImageDiff.diff(before_image, after_image)
    end
  end
end
