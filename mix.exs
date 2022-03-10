defmodule Dfecto.MixProject do
  use Mix.Project

  def project do
    [
      app: :dfecto,
      aliases: aliases(),
      compilers: [] ++ Mix.compilers(),
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]],
      elixir: "~> 1.13",
      elixirc_options: [warnings_as_errors: true],
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      releases: [
        dfecto: [
          applications: [dfecto: :permanent],
          cookie: "-ofzscpPx1QU-Z08RUwufA3jLs_Tm3-cmYBsXwnZjZE22t8FvYAa2w==",
          include_erts: false,
          include_executables_for: [:unix],
          steps: [:assemble, &copy_extra_files/1]
        ]
      ],
      version: "0.1.0"
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Dfecto.Application, []},
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:ecto_sql, "~> 3.6"},
      {:events_manager, github: "doofinder/events_manager", tag: "2.1.0"},
      {:floki, ">= 0.30.0", only: :test},
      # hackney required by sentry,
      {:hackney, "~> 1.18"},
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"},
      {:myxql, ">= 0.0.0"},
      {:plug_cowboy, "~> 2.5"},
      {:postgrex, ">= 0.0.0"},
      {:remote_ip, "~> 1.0"},
      {:reverse_proxy_plug, "~> 2.1"},
      {:sentry, "~> 8.0"},
      {:sweet_xml, "~> 0.6"},
      {:swoosh, "~> 1.3"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      consistency: ["format", "dialyzer", "credo --strict"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      setup: ["deps.get", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end

  # Extra function used to copy files into release.
  # You need to set the files or directory to be copied.
  # Take in mind that directories will be created the same in
  # the release path. Files will be copied in the root of the
  # release.
  defp copy_extra_files(release) do
    files = [
      "appspec.yml",
      "deploy/"
    ]

    Enum.each(files, fn item ->
      if File.dir?(item) do
        File.cp_r!(item, "#{release.path}/#{item}")
      else
        target = Path.split(item) |> List.last()
        File.cp!(item, "#{release.path}/#{target}")
      end
    end)

    release
  end
end
