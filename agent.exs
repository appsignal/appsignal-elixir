defmodule Appsignal.Agent do
  def version, do: "4a275d3"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "f8676db1685fa6df35d065fc829d5db33aea740f65b4e6e795d2a149154495c5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4a275d3/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "f8676db1685fa6df35d065fc829d5db33aea740f65b4e6e795d2a149154495c5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4a275d3/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "93bb9907d91e8ce7a5a3fcd6e81cbec7fde965b9e36192032c36d5d058bae60b",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4a275d3/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "93bb9907d91e8ce7a5a3fcd6e81cbec7fde965b9e36192032c36d5d058bae60b",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4a275d3/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "04bba827f4e74bf3bd6ebe7da07ede82417dc4fdca6fd4484c0af0bbca979e7e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4a275d3/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "04bba827f4e74bf3bd6ebe7da07ede82417dc4fdca6fd4484c0af0bbca979e7e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4a275d3/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "ae9714b731ecbe850959b2662b269af4c34abfa841cff6dbc8163793e408cb42",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4a275d3/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "3445eb0cf4cb5f69852fc9ee1d1691f9cb06ff9cbed1f41d9daa88e04cc755b9",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4a275d3/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "2820bd938abe4b46e444f30255a51e7580598ab67b645ec531c47a7d6f0000fc",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4a275d3/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "2820bd938abe4b46e444f30255a51e7580598ab67b645ec531c47a7d6f0000fc",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4a275d3/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
