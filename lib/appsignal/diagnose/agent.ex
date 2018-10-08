defmodule Appsignal.Diagnose.Agent do
  @nif Application.get_env(:appsignal, :appsignal_nif, Appsignal.Nif)

  def report do
    if @nif.loaded? do
      Appsignal.Nif.env_put("_APPSIGNAL_DIAGNOSE", "true")
      report_string = @nif.diagnose

      report =
        case Poison.decode(report_string) do
          {:ok, report} -> {:ok, report}
          {:error, _} -> {:error, report_string}
        end

      Appsignal.Nif.env_delete("_APPSIGNAL_DIAGNOSE")
      report
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
      Enum.each(report_definition(), fn {component, categories} ->
        print_component(report[component] || %{}, categories)
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
    Enum.each(tests, fn {test, definition} ->
      print_test(report[test] || %{}, definition)
    end)
  end

  defp print_test(report, definition) do
    IO.write("  #{definition[:label]}: ")

    case Map.fetch(definition[:values], report["result"]) do
      {:ok, value} -> IO.puts(value)
      :error -> IO.puts("-")
    end

    if report["error"], do: IO.puts("    Error: #{report["error"]}")
    if report["output"], do: IO.puts("    Output: #{report["output"]}")
  end

  defp report_definition do
    %{
      "extension" => %{
        "config" => %{
          "valid" => %{
            :label => "Extension config",
            :values => %{true => "valid", false => "invalid"}
          }
        }
      },
      "agent" => %{
        "boot" => %{
          "started" => %{
            :label => "Agent started",
            :values => %{true => "started", false => "not started"}
          }
        },
        "config" => %{
          "valid" => %{
            :label => "Agent config",
            :values => %{true => "valid", false => "invalid"}
          }
        },
        "logger" => %{
          "started" => %{
            :label => "Agent logger",
            :values => %{true => "started", false => "not started"}
          }
        },
        "lock_path" => %{
          "created" => %{
            :label => "Agent lock path",
            :values => %{true => "writable", false => "not writable"}
          }
        }
      }
    }
  end
end
