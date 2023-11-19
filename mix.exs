defmodule SnappyImageDiff.MixProject do
  use Mix.Project
  @version "0.1.0"

  def project do
    [
      app: :snappy_image_diff,
      version: @version,
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: [
        extras: "README.md",
        main: "readme"
      ],
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def package do
    [
      licenses: ["MIT"],
      maintainers: ["Martin Feckie"],
      links: %{
        "Github" => "https://github.com/mfeckie/snappy_image_diff"
      },
      files: ["lib", "native", "README.md", "mix.exs", "checksum-*.exs"],
      exclude_patterns: [
        "native/snappy_image_diff/target"
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:rustler, ">= 0.0.0", optional: true},
      {:rustler_precompiled, "~> 0.7"}
    ]
  end
end
