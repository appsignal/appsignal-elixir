defmodule Appsignal.Agent do
  def version, do: "ca32965"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "4536f611bf2e31137520fcbbf2175dd19e86d4ae8c1d2910b82cb63d67634a8e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ca32965/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "4536f611bf2e31137520fcbbf2175dd19e86d4ae8c1d2910b82cb63d67634a8e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ca32965/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "c5e0cfcc1a26bab694dda5297c9f34fd76d020709475062a2a5d7b1e11a02231",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ca32965/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "c5e0cfcc1a26bab694dda5297c9f34fd76d020709475062a2a5d7b1e11a02231",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ca32965/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "a6e45a2c4a9054cbfb71dcacd23c012dc01b4b0af40b356c67153ce728f57e16",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ca32965/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "a6e45a2c4a9054cbfb71dcacd23c012dc01b4b0af40b356c67153ce728f57e16",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ca32965/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "ec400854cc123e73655bb09ebc4554726a2658980cfe5347f36076f74dac0524",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ca32965/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "84250cf6d97893c584f779c7ad600e4e7d1b280eae36a76815173a83df85bd3a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ca32965/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "ce28eed8dd12e6886657517bc0e1da442fbad135e449fb3a430c35087ed13973",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ca32965/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "ce28eed8dd12e6886657517bc0e1da442fbad135e449fb3a430c35087ed13973",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/ca32965/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
