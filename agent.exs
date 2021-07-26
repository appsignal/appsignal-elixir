defmodule Appsignal.Agent do
  def version, do: "891c6b0"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "17203c5edae2463684f271216d32c9d5c57923c9730254b4a050392fea4e74a8",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/891c6b0/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "17203c5edae2463684f271216d32c9d5c57923c9730254b4a050392fea4e74a8",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/891c6b0/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "70db73144a1ee9475636512e6f55b0c7189ee6d2d390341d33fcaaece10b5a13",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/891c6b0/appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "70db73144a1ee9475636512e6f55b0c7189ee6d2d390341d33fcaaece10b5a13",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/891c6b0/appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "0ff967bd1d2d117cdc5a988adfd6083352f0ff3e3a18d8e85360b998ed08997e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/891c6b0/appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "5653c81adebbf7533a714556efae82bd6ed538e3fa44e880aa5630b72d266668",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/891c6b0/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "5653c81adebbf7533a714556efae82bd6ed538e3fa44e880aa5630b72d266668",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/891c6b0/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "b07919c0a18c8ed1b658dbf2717268d61ab88d1cc4665438e68d73a54334e1f8",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/891c6b0/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "23dc0715fed704ef65365cbc385aa8135c317d53844e3102e989dd8144b37039",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/891c6b0/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "c9758318ea45461f3cede1d232f730914eb115ea2c34199cf9031a45af8d2776",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/891c6b0/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "c9758318ea45461f3cede1d232f730914eb115ea2c34199cf9031a45af8d2776",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/891c6b0/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
