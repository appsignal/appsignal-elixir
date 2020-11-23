defmodule Appsignal.Agent do
  def version, do: "361340a"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "4e08cb0cef0ea7e30f8d507380b923f6cfa14adaea12c81804e118acd6395b57",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/361340a/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "4e08cb0cef0ea7e30f8d507380b923f6cfa14adaea12c81804e118acd6395b57",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/361340a/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "01c027b3e472cb39d844284fcc8ba532628c00731b912e0e9718646ed124ae6e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/361340a/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "01c027b3e472cb39d844284fcc8ba532628c00731b912e0e9718646ed124ae6e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/361340a/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "fe2038d6fa468fc23900fea6d8179d2b37d41d54f4ff33c573116183ac1cb491",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/361340a/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "b2ee5579a62b76a1d2f41f4e06749c4c549f9aaa40764862eff49c5a6a8841f1",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/361340a/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "f228dd2f2cf951c9eb9f04487be50fdfdc3d29a956e639787a4022bd73f02e53",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/361340a/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "f228dd2f2cf951c9eb9f04487be50fdfdc3d29a956e639787a4022bd73f02e53",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/361340a/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
