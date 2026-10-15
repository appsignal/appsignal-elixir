# Writes .github/workflows/ci.yaml from .github/build_matrix.exs.
#
#     elixir script/generate_ci.exs
#
# With --local, runs the test suite against every dependency set the
# installed Elixir version is tested with in CI, instead.
#
#     elixir script/generate_ci.exs --local

Mix.install([{:ymlr, "~> 5.1"}], consolidate_protocols: false)

defmodule GenerateCI.Mapping do
  @moduledoc false

  # A YAML mapping that keeps its keys in the order they are given, which
  # Elixir maps do not.
  defstruct [:pairs]

  def new(pairs), do: %__MODULE__{pairs: pairs}

  defimpl Ymlr.Encoder do
    def encode(mapping, indent_level, opts), do: Ymlr.Encode.map(mapping, indent_level, opts)
  end

  defimpl Enumerable do
    def reduce(%{pairs: pairs}, acc, fun), do: Enumerable.List.reduce(pairs, acc, fun)
    def count(%{pairs: pairs}), do: {:ok, length(pairs)}
    def member?(_mapping, _element), do: {:error, __MODULE__}
    def slice(_mapping), do: {:error, __MODULE__}
  end
end

defmodule GenerateCI do
  alias GenerateCI.Mapping

  @matrix_path ".github/build_matrix.exs"
  @workflow_path ".github/workflows/ci.yaml"

  @header """
  # This file is generated from .github/build_matrix.exs by
  # script/generate_ci.exs. Do not edit it by hand: edit the matrix and run
  #
  #     elixir script/generate_ci.exs
  """

  def main(["--local"]), do: run_locally(matrix())
  def main([]), do: File.write!(@workflow_path, workflow(matrix()))

  def main(_args) do
    IO.puts(:stderr, "Usage: elixir script/generate_ci.exs [--local]")
    System.halt(1)
  end

  defp matrix do
    {matrix, _binding} = Code.eval_file(@matrix_path)
    matrix
  end

  defp run_locally(matrix) do
    version = System.version()
    row = local_row(matrix[:elixir], version)

    unless row do
      IO.puts(:stderr, "Elixir #{version} is not in #{@matrix_path}.")
      System.halt(1)
    end

    otp = System.otp_release()

    sets =
      for {set, exclusions} <- sets(matrix),
          not excluded?(exclusions, row[:elixir], otp),
          do: set

    failed =
      Enum.reject([nil | sets], fn set ->
        env = [{"_APPSIGNAL_TEST_DEPS", set && to_string(set)}]
        IO.puts("\n==> Testing #{describe(set)}")
        mix(["deps.get"], env) == 0 and mix(["test"], env) == 0
      end)

    case failed do
      [] ->
        :ok

      _ ->
        IO.puts(:stderr, "Failed: #{Enum.map_join(failed, ", ", &describe/1)}")
        System.halt(1)
    end
  end

  defp local_row(rows, version) do
    Enum.find(rows, &(minor(&1[:elixir]) == minor(version)))
  end

  defp describe(nil), do: "without a dependency set"
  defp describe(set), do: "with the #{set} dependency set"

  defp minor(version), do: version |> String.split(".") |> Enum.take(2)

  defp mix(args, env) do
    {_output, status} = System.cmd("mix", args, env: env, into: IO.stream())
    status
  end

  # The dependency sets in test/deps, with the exclusions the matrix gives
  # them. The `all` set is only for the Dialyzer job.
  defp sets(matrix) do
    sets =
      "test/deps/*.exs"
      |> Path.wildcard()
      |> Enum.map(&Path.basename(&1, ".exs"))
      |> Enum.reject(&(&1 == "all"))
      |> Enum.sort()

    exclusions = Map.new(matrix[:exclude], fn {set, exclusion} -> {to_string(set), exclusion} end)

    case Map.keys(exclusions) -- sets do
      [] ->
        :ok

      unknown ->
        raise "#{@matrix_path} excludes sets that do not exist: #{Enum.join(unknown, ", ")}"
    end

    for set <- sets, do: {set, Map.get(exclusions, set, [])}
  end

  defp excluded?(exclusions, elixir, otp) do
    Enum.any?(exclusions, fn {key, requirement} ->
      version = %{elixir: elixir, otp: otp} |> Map.fetch!(key) |> full_version()
      version != nil and Version.match?(version, full_version(requirement))
    end)
  end

  # Pads every version in a version or requirement to three parts, so `"26"`
  # and `"< 1.15"` can be matched. A version that is not a number, such as
  # `"main"`, is never excluded.
  defp full_version(version) do
    if version =~ ~r/\d/ do
      Regex.replace(~r/\d+(\.\d+)*/, version, fn number, _ ->
        number |> String.split(".") |> Kernel.++(["0", "0"]) |> Enum.take(3) |> Enum.join(".")
      end)
    end
  end

  defp workflow(matrix) do
    set_jobs = for {set, exclusions} <- sets(matrix), do: set_job(matrix, set, exclusions)

    jobs =
      static_jobs(matrix) ++
        [lint_compile_job(matrix), test_job(matrix)] ++ set_jobs ++ [all_job(matrix)]

    sections = [
      [name: "Elixir package CI"],
      [
        on: [
          push: [branches: ["main", "develop"]],
          pull_request: [types: ["opened", "reopened", "synchronize"]],
          schedule: [[cron: "0 0 * * 1-5"]]
        ]
      ],
      "jobs:\n" <> Enum.map_join(jobs, "\n", &indent(yaml([&1])))
    ]

    @header <> Enum.map_join(sections, "\n", &yaml/1)
  end

  defp yaml(section) when is_binary(section), do: section
  defp yaml(section), do: Ymlr.Encode.to_s!(mapping(section)) <> "\n"

  defp indent(yaml), do: String.replace(yaml, ~r/^(?=.)/m, "  ")

  defp static_jobs(matrix) do
    setup = lint_setup_beam(matrix)

    [
      "validate-changesets": [uses: "./.github/workflows/validate_changesets.yaml"],
      lint_git: [
        "runs-on": "ubuntu-latest",
        if: "${{ github.event_name != 'schedule' }}",
        steps: [
          [uses: "actions/checkout@v4", with: ["fetch-depth": 0]],
          [uses: "lintje/action@v0.11"]
        ]
      ],
      lint_ci: [
        "runs-on": "ubuntu-latest",
        steps: [
          setup,
          checkout(),
          [name: "Generate the CI workflow", run: "elixir script/generate_ci.exs"],
          [
            name: "Check the CI workflow is up to date",
            run: "git diff --exit-code .github/workflows/ci.yaml"
          ]
        ]
      ],
      lint_format: [
        "runs-on": "ubuntu-latest",
        steps: [
          setup,
          checkout(),
          [name: "Check code formatting", run: "mix format --check-formatted"]
        ]
      ],
      lint_credo: [
        "runs-on": "ubuntu-latest",
        steps: [
          setup,
          checkout(),
          deps_get(),
          [name: "Analyze code with Credo", run: "mix credo --strict"]
        ]
      ],
      lint_dialyzer: [
        "runs-on": "ubuntu-latest",
        strategy: ["fail-fast": false, matrix: [set: ["", "all"]]],
        env: [MIX_ENV: "test", _APPSIGNAL_TEST_DEPS: "${{matrix.set}}"],
        steps: [
          setup,
          [
            name: "PLT cache",
            uses: "actions/cache@v4",
            id: "plt_cache",
            with: [key: "plt-${{matrix.set}}", path: "priv/plts"]
          ],
          checkout(),
          deps_get(),
          [name: "Compile", run: "mix compile"],
          [name: "Analyze code with Dialyzer", run: "mix dialyzer --format github"]
        ]
      ],
      test_diagnose: [
        "runs-on": "ubuntu-latest",
        steps: [
          setup,
          [name: "Set up Ruby", uses: "ruby/setup-ruby@v1", with: ["ruby-version": "3.3.3"]],
          checkout(with: [submodules: true]),
          deps_get(),
          [name: "Run tests", run: "LANGUAGE=elixir test/integration/diagnose/bin/test"]
        ]
      ],
      test_no_nif: [
        "runs-on": "ubuntu-latest",
        steps: [
          setup,
          checkout(),
          deps_get(),
          [name: "Run tests", run: "MIX_ENV=test_no_nif mix test"]
        ]
      ]
    ]
  end

  # Compiles once without a dependency set, which checks that the package
  # builds in an application with none of the libraries it integrates with,
  # and once with each set.
  defp lint_compile_job(matrix) do
    [[elixir: elixir, otp: [otp | _]] | _] = matrix[:elixir]

    sets =
      for {set, exclusions} <- sets(matrix), not excluded?(exclusions, elixir, otp), do: set

    {:lint_compile,
     [
       "runs-on": "ubuntu-latest",
       strategy: ["fail-fast": false, matrix: [set: ["" | sets]]],
       env: [_APPSIGNAL_TEST_DEPS: "${{matrix.set}}"],
       steps: [
         lint_setup_beam(matrix),
         checkout(),
         deps_get(),
         [
           name: "Check for compilation errors",
           run: "MIX_ENV=test mix compile --warnings-as-errors"
         ]
       ]
     ]}
  end

  defp test_job(matrix) do
    rows = for row <- matrix[:elixir], otp <- row[:otp], do: {row[:elixir], otp}

    {:test,
     [
       "runs-on": "ubuntu-latest",
       strategy: ["fail-fast": false, matrix: [include: include(rows)]],
       steps: [
         setup_beam("${{matrix.elixir}}", "${{matrix.otp}}"),
         checkout(),
         deps_get(),
         [name: "Run tests", run: "mix test"]
       ]
     ]}
  end

  defp set_job(matrix, set, exclusions) do
    rows =
      for row <- matrix[:elixir],
          otp <- row[:otp],
          not excluded?(exclusions, row[:elixir], otp),
          do: {row[:elixir], otp}

    {set_job_id(set),
     [
       name: "test (#{set}, ${{matrix.elixir}}, OTP ${{matrix.otp}})",
       needs: "test",
       "runs-on": "ubuntu-latest",
       strategy: ["fail-fast": false, matrix: [include: include(rows)]],
       env: [_APPSIGNAL_TEST_DEPS: to_string(set)],
       steps: [
         setup_beam("${{matrix.elixir}}", "${{matrix.otp}}"),
         checkout(),
         deps_get(),
         [name: "Run tests", run: "mix test"]
       ]
     ]}
  end

  # A single job that depends on every other one, to require as the status
  # check for pull requests.
  defp all_job(matrix) do
    needs =
      ~w(validate-changesets lint_git lint_ci lint_format lint_credo lint_dialyzer
         lint_compile test_diagnose test_no_nif test) ++
        Enum.map(sets(matrix), fn {set, _} -> to_string(set_job_id(set)) end)

    {:all,
     [
       "runs-on": "ubuntu-latest",
       if: "${{ always() }}",
       needs: needs,
       steps: [
         [
           name: "Check that every job succeeded or was skipped",
           if:
             "${{ contains(needs.*.result, 'failure') || contains(needs.*.result, 'cancelled') }}",
           run: "exit 1"
         ]
       ]
     ]}
  end

  defp lint_setup_beam(matrix) do
    [[elixir: elixir, otp: [otp | _]] | _] = matrix[:elixir]
    setup_beam(elixir, otp)
  end

  defp setup_beam(elixir, otp) do
    [
      name: "Set up Erlang and Elixir",
      uses: "erlef/setup-beam@v1",
      with: ["otp-version": otp, "elixir-version": elixir]
    ]
  end

  defp checkout(options \\ []),
    do: [name: "Checkout code", uses: "actions/checkout@v4"] ++ options

  defp deps_get, do: [name: "Get dependencies", run: "mix deps.get"]

  defp set_job_id(set), do: String.to_atom("test_" <> String.replace(to_string(set), ".", "_"))

  defp include(rows), do: for({elixir, otp} <- rows, do: [elixir: elixir, otp: otp])

  # Keyword lists become mappings, in their order; every other list stays a
  # sequence.
  defp mapping([{key, _} | _] = pairs) when is_atom(key) do
    Mapping.new(for {key, value} <- pairs, do: {key, mapping(value)})
  end

  defp mapping(list) when is_list(list), do: Enum.map(list, &mapping/1)
  defp mapping(value), do: value
end

GenerateCI.main(System.argv())
