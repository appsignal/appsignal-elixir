defmodule Appsignal.Agent do
  def version, do: "4548c88"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "322340b402d7750c107bc2c83be46598b3ec0baab27ab7083c6b49dde236cd45",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4548c88/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "322340b402d7750c107bc2c83be46598b3ec0baab27ab7083c6b49dde236cd45",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4548c88/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "08addb14f53856cc1befcc4428bef7541e04ea733deb4bf600904cc780de95f5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4548c88/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "08addb14f53856cc1befcc4428bef7541e04ea733deb4bf600904cc780de95f5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4548c88/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "b9d3419bcca5a2fe07179af29b8e0fd26df73be46b18e9edaf1049d162eefed4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4548c88/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "b9d3419bcca5a2fe07179af29b8e0fd26df73be46b18e9edaf1049d162eefed4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4548c88/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "4befb33b621cb1d273b5dec9f3395271d4ecfe1d637d5f311c80bac105a06b4b",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4548c88/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "49b95f4c3d025b633e22632ca7b401b56d8acd448a545be3976466676d5aed54",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4548c88/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "b8734f66d077e9acd9fc990c812877b92e4fc783ee30f430d829da058d3a709f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4548c88/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "b8734f66d077e9acd9fc990c812877b92e4fc783ee30f430d829da058d3a709f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/4548c88/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
