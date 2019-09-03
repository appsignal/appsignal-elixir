defmodule Appsignal.Agent do
  def version, do: "e1c9363"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "27c9a6de8ee9cd27bc3021e9f5a0814923814a72be0dfc901e1adf49840181f3",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1c9363/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "27c9a6de8ee9cd27bc3021e9f5a0814923814a72be0dfc901e1adf49840181f3",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1c9363/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "55085bbdbb802bb1fb1f451fc13387360eff9aa9eaf5c4e8f6380692bd3d7c5a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1c9363/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "55085bbdbb802bb1fb1f451fc13387360eff9aa9eaf5c4e8f6380692bd3d7c5a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1c9363/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "27f86f2b5b0be80980fd7e72557c3aff5fc6bed6eada97f09f53bf2c74723e0a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1c9363/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "27f86f2b5b0be80980fd7e72557c3aff5fc6bed6eada97f09f53bf2c74723e0a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1c9363/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "3eff05e641c5c4a2a2dd3945bd0b96ac191cb229ded9181ee317e78539d8cd1d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1c9363/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "4bbea5ec8a1301dc4a3eb4a764a0daddff6d34dad7937d0b3839c1f827b11542",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1c9363/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "2091e45c6cd11721b2b3cf6db927b360e36c5596ef36f292ba38c60f63102e6d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1c9363/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "2091e45c6cd11721b2b3cf6db927b360e36c5596ef36f292ba38c60f63102e6d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e1c9363/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
