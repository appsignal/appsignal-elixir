defmodule Appsignal.Agent do
  def version, do: "ea78a58"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "f3546e3e99823d5079dd2424f776be9aa51a736b7a36573902076f5c01e85d11",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ea78a58/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "f3546e3e99823d5079dd2424f776be9aa51a736b7a36573902076f5c01e85d11",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ea78a58/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "82708a13163fa6e03860a8d3c06e0617a4c15cca08fab29e6f2761752374d927",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ea78a58/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "82708a13163fa6e03860a8d3c06e0617a4c15cca08fab29e6f2761752374d927",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ea78a58/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "01dcbeea6e39976d0da4ec36b16ecf6af4bf1f6821e0452671999129a541e6e4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ea78a58/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "01dcbeea6e39976d0da4ec36b16ecf6af4bf1f6821e0452671999129a541e6e4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ea78a58/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "c40ac2149c30bbc66b448685941c30965f9ab19f62cb4af37d437d0da3fb6760",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ea78a58/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "694618273ef00e3cce1b156770eee51dfb3c31be5ee16d8e61e1c3970a943705",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ea78a58/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "666b3ec59f03fa8ae3c87348065866f30d9f868a4402809b9e5036214da943d5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ea78a58/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "666b3ec59f03fa8ae3c87348065866f30d9f868a4402809b9e5036214da943d5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ea78a58/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
