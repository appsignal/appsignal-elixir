defmodule Appsignal.Agent do
  def version, do: "9f282f3"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "c279d061ac04b53c8e2ea21b7714d4d54964495124ddc7e794ba998366f9c195",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/9f282f3/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "c279d061ac04b53c8e2ea21b7714d4d54964495124ddc7e794ba998366f9c195",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/9f282f3/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "3054b6e3bcab8c8959d4e87eb6fd9fc7a5821e0986c8e733154c2b76251c9e70",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/9f282f3/appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "30554989a59632cdaf8fdf5d15024b866d32930e91c080425955842e8078952b",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/9f282f3/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "30554989a59632cdaf8fdf5d15024b866d32930e91c080425955842e8078952b",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/9f282f3/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "f11fa7ec493c3668e965ef4cff077d44fe55101197a5eeaf50ccacf7314eba2b",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/9f282f3/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "0dae02e77e244275b69bb8332e79bdcb0e0fa3b6b6f84744780ce0baffa9784f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/9f282f3/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "d9146a04bbbb85dccf22c84cacfa924ee8b7e2ff8ed79402aba14ac4333e440f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/9f282f3/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "d9146a04bbbb85dccf22c84cacfa924ee8b7e2ff8ed79402aba14ac4333e440f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/9f282f3/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
