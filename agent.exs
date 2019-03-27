defmodule Appsignal.Agent do
  def version, do: "108f833"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "fbdb72f3b0ac326de267c157c58259444b8bb44ef998225e042d63a4ef8e0fac",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/108f833/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "fbdb72f3b0ac326de267c157c58259444b8bb44ef998225e042d63a4ef8e0fac",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/108f833/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "7b336011798d6c9a5777ff2bc6cb51e954bf55e5218d9201e285326bbbae18b1",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/108f833/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "7b336011798d6c9a5777ff2bc6cb51e954bf55e5218d9201e285326bbbae18b1",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/108f833/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "5670adfd22815350f2e6a04b0602429b04fbf98b7ffeda89a5cfcf0dd670ccc0",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/108f833/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "5670adfd22815350f2e6a04b0602429b04fbf98b7ffeda89a5cfcf0dd670ccc0",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/108f833/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "e740815301dfb09b4e8dc3e8dd904c16794f56b576ea715877652874561eb20d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/108f833/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "6c797166fd077a360790d257c971c24603a89d507a933b97fcac1120b35ae5b5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/108f833/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "2581f58e6ce63975cb2100242adda96f4710c1e51731e66b6ab668203b338c14",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/108f833/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "2581f58e6ce63975cb2100242adda96f4710c1e51731e66b6ab668203b338c14",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/108f833/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
