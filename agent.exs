defmodule Appsignal.Agent do
  def version, do: "01362a4"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "a33aa14ae9b8c58c379667e7f79807bdc843354baf635abc334a14c3b984114d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/01362a4/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "a33aa14ae9b8c58c379667e7f79807bdc843354baf635abc334a14c3b984114d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/01362a4/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "44d729dd8b3c6bf3041ee32dee1c155bfd19b5309cbf6ef95959fc026819915c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/01362a4/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "44d729dd8b3c6bf3041ee32dee1c155bfd19b5309cbf6ef95959fc026819915c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/01362a4/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "0bb69e60781db9bd0867ccece63a029706cf0d5a26d34d70668bc2264b531ce4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/01362a4/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "0bb69e60781db9bd0867ccece63a029706cf0d5a26d34d70668bc2264b531ce4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/01362a4/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "92b3662722978b39176c9d2e986fb8cc527772470dd0d9d7a8ea808cd4780b70",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/01362a4/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "41624a50b603eeb4f875ee19dde41bb0877a0a039f6f2f560a9efc3d6b73a195",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/01362a4/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "14cdca07045a53b2c69647f1255cbc2f9fe322ddf6040c2e1a6ba36aa482cdf2",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/01362a4/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "14cdca07045a53b2c69647f1255cbc2f9fe322ddf6040c2e1a6ba36aa482cdf2",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/01362a4/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
