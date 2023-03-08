defmodule CrackHashManager.MixProject do
  use Mix.Project

  def project do
    [
      app: :crack_hash_manager,
      version: "0.1.0",
      elixir: "~> 1.14.3",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {CrackHashManager.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Web server
      {:bandit, ">= 0.6.9"},
      # Static code consistency analysis
      {:credo, "~> 1.6", only: :dev, runtime: false},
      # Static code types analysis
      {:dialyxir, "~> 1.2", only: :dev, runtime: false},
      # Docs build
      {:ex_doc, "~> 0.29.2", only: :dev, runtime: false},
      # Test coverage
      {:excoveralls, "~> 0.16", only: :test},
      # Docs coverage
      {:inch_ex, "~> 2.0", only: [:dev, :test]},
      # Json encode/decode
      {:poison, "~> 5.0"}
    ]
  end
end
