defmodule Appsignal.SystemBehaviour do
  @callback priv_dir() :: String.t
  @callback hostname_with_domain() :: String.t | nil
  @callback root?() :: boolean()
  @callback heroku?() :: boolean()
  @callback uid() :: integer | nil
  @callback agent_platform() :: String.t
end

defmodule Appsignal.System do
  @behaviour Appsignal.SystemBehaviour
  @os Application.get_env(:appsignal, :os, :os)

  def priv_dir() do
    case :code.priv_dir(:appsignal) do
      {:error, :bad_name} ->
        # This happens on initial compilation
        Mix.Tasks.Compile.Erlang.manifests
        |> List.first
        |> Path.dirname
        |> String.trim_trailing(".mix")
        |> Path.join("priv")
      path ->
        path
        |> List.to_string
    end
  end

  @doc """
  Get the full host name, including the domain.
  """
  def hostname_with_domain do
    case :inet_udp.open(0) do
      {:ok, port} ->
        {:ok, hostname} = :inet.gethostname(port)
        :inet_udp.close(port)
        to_string(hostname)
      _ -> nil
    end
  end

  def heroku? do
    System.get_env("DYNO") != nil
  end

  def root? do
    uid() == 0
  end

  def uid do
    case System.cmd("id", ["-u"]) do
      {id, 0} ->
        case Integer.parse(List.first(String.split(id, "\n"))) do
          {int, _} -> int
          :error -> nil
        end
      {_, _} -> nil
    end
  end

  # Returns the platform for which the agent was installed.
  #
  # This value is saved when the package is installed.
  # We use this value to build the diagnose report with the installed
  # platform, rather than the detected platform in .agent_platform during
  # the diagnose run.
  def installed_agent_architecture do
    case File.read(Path.join([priv_dir(), "appsignal.architecture"])) do
      {:ok, arch} -> arch
      {:error, _} -> nil
    end
  end

  def agent_platform do
    case force_musl_build?() do
      true -> "linux-musl"
      false ->
        case @os.type do
          {:unix, :linux} ->
            agent_platform_by_ldd_version()
          {_, os} ->
            to_string(os)
        end
    end
  end

  defp agent_platform_by_ldd_version do
    try do
      {output, _} = System.cmd("ldd", ["--version"], stderr_to_stdout: true)
      case String.contains?(output, "musl") do
        true -> "linux-musl"
        false ->
          ldd_version = List.first(Regex.run(~r/\d+\.\d+/, output))
          case Version.compare("#{ldd_version}.0", "2.15.0") do
            :lt -> "linux-musl"
            _ -> "linux"
          end
      end
    rescue
      _ -> "linux"
    end
  end

  defp force_musl_build? do
    !is_nil(System.get_env("APPSIGNAL_BUILD_FOR_MUSL"))
  end
end
