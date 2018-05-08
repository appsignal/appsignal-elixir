defmodule Appsignal.Agent do
  def version, do: "e509c90"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "f80f79f80afee3bdfb5f09f58503e6912fe14b74311baf07ac4f888f645e1b0d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e509c90/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "f80f79f80afee3bdfb5f09f58503e6912fe14b74311baf07ac4f888f645e1b0d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e509c90/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "8f93646fe4d9769d7f132d7bd2fae4ef48cd12daff341b58e142ac4a29ff3cd0",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e509c90/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "8f93646fe4d9769d7f132d7bd2fae4ef48cd12daff341b58e142ac4a29ff3cd0",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e509c90/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "460de28c80c8e892ed7b21e9e2c8fe14027a4de36145735c09df393904aac90b",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e509c90/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "460de28c80c8e892ed7b21e9e2c8fe14027a4de36145735c09df393904aac90b",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e509c90/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "0de52c7fee6e651441ff11384e25e8d5c72065e7f99997ff32babd15d7ca2317",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e509c90/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "c49e094d2a9894c98538e11aa7e519619e08daf30d7b7ae4d38e10bb44e14084",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e509c90/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "ad939a8919edfab55a442faebaf6095584a690e4b6a08a288ac7630b2069799c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e509c90/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "ad939a8919edfab55a442faebaf6095584a690e4b6a08a288ac7630b2069799c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e509c90/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
