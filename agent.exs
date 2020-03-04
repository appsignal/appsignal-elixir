defmodule Appsignal.Agent do
  def version, do: "6cff3d8"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "6624e4c43fe43154620a50314d3289199c50663050774a670d8b06b7924326d7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6cff3d8/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "6624e4c43fe43154620a50314d3289199c50663050774a670d8b06b7924326d7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6cff3d8/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "e36594765e2dd0d401fe973702519debb17c4340c0faf911ea3600d95aa44d73",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6cff3d8/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "e36594765e2dd0d401fe973702519debb17c4340c0faf911ea3600d95aa44d73",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6cff3d8/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "46c1ebdab5520c7940878667645338234d2ed88a58a36201d95fdc52359da123",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6cff3d8/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "46c1ebdab5520c7940878667645338234d2ed88a58a36201d95fdc52359da123",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6cff3d8/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "d3adf50b8fd357ff27aaf64b84be75b227bc977c557a577e89fd6841316ffac6",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6cff3d8/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "b413f20d2dabc0b0d8184a5c566cb02959eb420fbf4a4c169059fd5cad293c27",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6cff3d8/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "b11203af2f893d503b22b1ef91a476f269f97d8d1a4b81c317a31e24f5e916dd",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6cff3d8/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "b11203af2f893d503b22b1ef91a476f269f97d8d1a4b81c317a31e24f5e916dd",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6cff3d8/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
