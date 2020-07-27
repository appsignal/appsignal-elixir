defmodule Appsignal.Agent do
  def version, do: "c8f8185"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "8fad088047d8c73e5c0cf9213c20873ad591881d4f7059b178d8eeb89255f73e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c8f8185/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "8fad088047d8c73e5c0cf9213c20873ad591881d4f7059b178d8eeb89255f73e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c8f8185/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "0e8c4436684824a325fa1b581f6fad88598c529307b2b5ad0cc2620d22d2782f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c8f8185/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "0e8c4436684824a325fa1b581f6fad88598c529307b2b5ad0cc2620d22d2782f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c8f8185/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "28b69e895da6b2a30402eed29cf8c3bbc4f647d6ce9cc5e0b11b4a771d7a1021",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c8f8185/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "28b69e895da6b2a30402eed29cf8c3bbc4f647d6ce9cc5e0b11b4a771d7a1021",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c8f8185/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "fb457dc39e005bb8f241e1e260bb9ea0460cf922db5e30f514dda8afa0bd57bc",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c8f8185/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "cf469d6e3ee1dc6ccb9762a996355ecc407b9a906b9c0a0b6742363347ec9494",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c8f8185/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "5c50e4776dbd0defe7d99015650e85d7983222ea27bd7b586b4c92f7b8336eee",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c8f8185/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "5c50e4776dbd0defe7d99015650e85d7983222ea27bd7b586b4c92f7b8336eee",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c8f8185/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
