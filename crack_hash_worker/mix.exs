defmodule CrackHashWorker.MixProject do
  use Mix.Project

  def project do
    [
      app: :crack_hash_worker,
      version: "0.1.0",
      elixir: ">= 1.14.2",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      releases: [
        main: [include_executables_for: [:unix]]
      ],
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
      extra_applications: [:logger, :elixir_xml_to_map],
      mod: {CrackHashWorker.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # RabbitMQ
      {:amqp, "~> 3.2.0"},
      # RabbitMQ consumer
      {:broadway, "~> 1.0.6"},
      {:broadway_rabbitmq, "~> 0.7.2"},
      # Web server
      {:bandit, ">= 0.7.1"},
      # Static code consistency analysis
      {:credo, "~> 1.6", only: :dev, runtime: false},
      # Static code types analysis
      {:dialyxir, "~> 1.2", only: :dev, runtime: false},
      # Parsing xml
      {:elixir_xml_to_map, "~> 2.0"},
      # Docs build
      {:ex_doc, "~> 0.29.2", only: :dev, runtime: false},
      # Test coverage
      {:excoveralls, "~> 0.16", only: :test},
      # Docs coverage
      {:inch_ex, "~> 2.0", only: [:dev, :test]},
      # Concurrent computations
      {:flow, "~> 1.2"},
      # HTTP Client
      {:finch, "~> 0.15"},
      # Mocking in tests
      {:mock, "~> 0.3.0", only: :test}
    ]
  end
end
