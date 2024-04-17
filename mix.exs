defmodule UnverifiedMox.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      package: package(),
      description: description(),
      app: :unverified_mox,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/carsdotcom/unverified_mox"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      name: "CredoMox",
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => "https://github.com/carsdotcom/unverified_mox"}
    ]
  end

  defp description do
    "Credo checks for Mox"
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end
end
