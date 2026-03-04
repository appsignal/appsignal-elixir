defmodule FakeErlang do
  use TestAgent, %{system_architecture: ~c"x86_64-apple-darwin20.2.0"}

  def system_info(:system_architecture), do: get(__MODULE__, :system_architecture)
  def system_info(key), do: :erlang.system_info(key)
end

defmodule FakeAgent do
  # SHA256 of "" (empty string) — matches FakeFinchDownload's default response body
  @empty_checksum "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"

  use TestAgent, %{
    version: "0.0.1-test",
    mirrors: ["http://fake-mirror"],
    triples: %{
      "x86_64-linux" => %{
        checksum: @empty_checksum,
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: @empty_checksum,
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      }
    }
  }

  def version, do: get(__MODULE__, :version)
  def mirrors, do: get(__MODULE__, :mirrors)
  def triples, do: get(__MODULE__, :triples)
end

defmodule FakeFinchDownload do
  use TestAgent, %{
    response: {:ok, %{status: 200, body: ""}},
    response_queue: [],
    last_request: nil
  }

  # Spawn a throwaway process so Process.exit(pid, :normal) in the after
  # block of download_package/2 doesn't kill the test process
  def start_link(name: _name) do
    pid = spawn(fn -> :ok end)
    {:ok, pid}
  end

  def build(method, url, headers, body) do
    {:fake_request, method, url, headers, body}
  end

  def request({:fake_request, method, url, headers, body}, _name, _opts) do
    if alive?() do
      update(__MODULE__, :last_request, {method, url, headers, body})
      next_response()
    else
      {:error, :not_started}
    end
  end

  defp next_response do
    Agent.get_and_update(__MODULE__, fn state ->
      case state[:response_queue] do
        [response | rest] -> {response, Map.put(state, :response_queue, rest)}
        [] -> {state[:response], state}
      end
    end)
  end
end

defmodule FakeExtractor do
  use TestAgent, %{result: :ok}

  def extract(_filename, _dir), do: get(__MODULE__, :result)
end

defmodule FakeDownloadCache do
  use TestAgent, %{exists: false, body: ""}

  def exists?(_path), do: get(__MODULE__, :exists)

  def write(_path, body) do
    update(__MODULE__, :body, body)
    :ok
  end

  def read!(_path), do: get(__MODULE__, :body)
end

defmodule FakeExtensionDir do
  def prepare!(_dir), do: :ok
end

defmodule FakeInstalledVersion do
  use TestAgent, %{result: {:ok, "0.0.1-test"}}

  def read(_priv_dir), do: get(__MODULE__, :result)
end

defmodule FakeMake do
  use TestAgent, %{result: {"", 0}}

  def run(_env), do: get(__MODULE__, :result)
end

defmodule FakeLdd do
  use TestAgent, %{result: {:error, :not_available}}

  def version_output, do: get(__MODULE__, :result)
end

defmodule FakeRoot do
  def root?, do: false
end

defmodule FakeCachedBuild do
  use TestAgent, %{result: false}

  def installed?(_priv_dir, _expected_version), do: get(__MODULE__, :result)
end

defmodule FakeReportWriter do
  use TestAgent, %{}

  def write_install_report(report), do: update(__MODULE__, :install, report)
  def write_download_report(report), do: update(__MODULE__, :download, report)

  def get_install_report, do: get(__MODULE__, :install)
  def get_download_report, do: get(__MODULE__, :download)
end
