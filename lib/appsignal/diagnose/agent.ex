defmodule Appsignal.Diagnose.Agent do
  @moduledoc false

  @nif Application.compile_env(:appsignal, :appsignal_nif, Appsignal.Nif)

  def report do
    if @nif.loaded?() do
      report_string = to_string(@nif.diagnose)

      case Jason.decode(report_string) do
        {:ok, report} -> {:ok, report}
        {:error, _} -> {:error, report_string}
      end
    else
      {:error, :nif_not_loaded}
    end
  end

  # Start AppSignal as usual, in diagnose mode, so that it exits early, but
  # does go through the whole process of setting the config to the
  # environment.
  def print(report) do
    IO.puts("Agent diagnostics")

    if report["error"] do
      IO.puts("  Error: #{report["error"]}")
    else
      Enum.each(report_definition(), fn definition ->
        IO.puts("  #{definition[:label]}")
        print_component(report[definition[:key]] || %{}, definition[:tests])
      end)
    end

    IO.puts("")
  end

  defp print_component(report, categories) do
    Enum.each(categories, fn {category, tests} ->
      print_category(report[category] || %{}, tests)
    end)
  end

  defp print_category(report, tests) do
    Enum.each(tests, fn test ->
      print_test(
        report[test[:key]] || %{},
        test
      )
    end)
  end

  defp print_test(report, definition) do
    IO.write("    #{definition[:label]}: ")
    result = report["result"]

    display_value =
      case Map.has_key?(definition, :values) do
        true ->
          case Map.fetch(definition[:values], report["result"]) do
            {:ok, value} -> value
            :error -> nil
          end

        false ->
          result
      end

    display_value =
      case display_value do
        value when value in [nil, ""] -> "-"
        value -> value
      end

    IO.puts(display_value)
    if report["error"], do: IO.puts("      Error: #{report["error"]}")
    if report["output"], do: IO.puts("      Output: #{report["output"]}")
  end

  defp report_definition do
    [
      %{
        :key => "extension",
        :label => "Extension tests",
        :tests => [
          {
            "config",
            [
              %{
                :key => "valid",
                :label => "Configuration",
                :values => %{true: "valid", false: "invalid"}
              }
            ]
          }
        ]
      },
      %{
        :key => "agent",
        :label => "Agent tests",
        :tests => [
          {
            "boot",
            [
              %{
                :key => "started",
                :label => "Started",
                :values => %{true: "started", false: "not started"}
              }
            ]
          },
          {
            "host",
            [
              %{
                :key => "uid",
                :label => "Process user id"
              },
              %{
                :key => "gid",
                :label => "Process user group id"
              }
            ]
          },
          {
            "config",
            [
              %{
                :key => "valid",
                :label => "Configuration",
                :values => %{true: "valid", false: "invalid"}
              }
            ]
          },
          {
            "logger",
            [
              %{
                :key => "started",
                :label => "Logger",
                :values => %{true: "started", false: "not started"}
              }
            ]
          },
          {
            "working_directory_stat",
            [
              %{
                :key => "uid",
                :label => "Working directory user id"
              },
              %{
                :key => "gid",
                :label => "Working directory user group id"
              },
              %{
                :key => "mode",
                :label => "Working directory permissions"
              }
            ]
          },
          {
            "lock_path",
            [
              %{
                :key => "created",
                :label => "Lock path",
                :values => %{true: "writable", false: "not writable"}
              }
            ]
          }
        ]
      }
    ]
  end
end
