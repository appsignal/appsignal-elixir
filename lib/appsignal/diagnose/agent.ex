defmodule Appsignal.Diagnose.Agent do
  @nif Application.get_env(:appsignal, :appsignal_nif, Appsignal.Nif)

  def report do
    if @nif.loaded? do
      Appsignal.Nif.env_put("_APPSIGNAL_DIAGNOSE", "true")
      report_string = @nif.diagnose
      report = case Poison.decode(report_string) do
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
    IO.puts "Agent diagnostics"
    if report["error"] do
      IO.puts "  Error: #{report["error"]}"
    else
      Enum.each(report_definition(), fn({component, definition}) ->
        IO.puts "  #{definition[:label]}"
        print_component(report[component] || %{}, definition[:tests])
      end)
    end
    IO.puts ""
  end

  defp print_component(report, categories) do
    Enum.each(categories, fn({category, tests}) ->
      print_category(report[category] || %{}, tests)
    end)
  end

  defp print_category(report, tests) do
    Enum.each(tests, fn({test, definition}) ->
      print_test(report[test] || %{}, definition)
    end)
  end

  defp print_test(report, definition) do
    IO.write "    #{definition[:label]}: "
    result = report["result"]
    display_value =
      case Map.has_key?(definition, :values) do
        true ->
          case Map.fetch(definition[:values], report["result"]) do
            {:ok, value} -> value
            :error -> nil
          end
        false -> result
      end
    display_value =
      case display_value do
        value when value in [nil, ""] -> "-"
        value -> value
      end
    IO.puts display_value
    if report["error"], do: IO.puts "      Error: #{report["error"]}"
    if report["output"], do: IO.puts "      Output: #{report["output"]}"
  end

  defp report_definition do
    %{
      "extension" => %{
        :label => "Extension tests",
        :tests => %{
          "config" => %{
            "valid" => %{
              :label => "Configuration",
              :values => %{ true => "valid", false => "invalid" }
            }
          }
        }
      },
      "agent" => %{
        :label => "Agent tests",
        :tests => %{
          "boot" => %{
            "started" => %{
              :label => "Started",
              :values => %{ true => "started", false => "not started" }
            }
          },
          "host" => %{
            "uid" => %{ :label => "Process user id" },
            "gid" => %{ :label => "Process user group id" }
          },
          "config" => %{
            "valid" => %{
              :label => "Configuration",
              :values => %{ true => "valid", false => "invalid" }
            }
          },
          "logger" => %{
            "started" => %{
              :label => "Logger",
              :values => %{ true => "started", false => "not started" }
            }
          },
          "working_directory_stat" => %{
            "uid" => %{ :label => "Working directory user id" },
            "gid" => %{ :label => "Working directory user group id" },
            "mode" => %{ :label => "Working directory permissions" }
          },
          "lock_path" => %{
            "created" => %{
              :label => "Lock path",
              :values => %{ true => "writable", false => "not writable" }
            }
          }
        }
      }
    }
  end
end
