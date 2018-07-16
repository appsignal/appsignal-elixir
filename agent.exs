defmodule Appsignal.Agent do
  def version, do: "e41c3c0"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "29137003b8e4fdec8528cf68d800b08cab15cfdcdcb89535b50e2d76641ff9da",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e41c3c0/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "29137003b8e4fdec8528cf68d800b08cab15cfdcdcb89535b50e2d76641ff9da",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e41c3c0/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "ab930cd56bc0337ac34704a42bcd2d86f3c75f3bfdb8e1b41e600a0ba4f53e42",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e41c3c0/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "ab930cd56bc0337ac34704a42bcd2d86f3c75f3bfdb8e1b41e600a0ba4f53e42",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e41c3c0/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "18d37d334a0726de0fa39e4f8b657987350b452664c744d24774a960a54511f7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e41c3c0/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "18d37d334a0726de0fa39e4f8b657987350b452664c744d24774a960a54511f7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e41c3c0/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "bdf586ecaf7c0c311fc41d3f62f3dc6eee8d4334e10306b5cd82d97bc35c3031",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e41c3c0/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "67fbeda8e308e25657bcce32cdfd0fc3bbe4725f62a6661e76450e57a4aed2d9",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e41c3c0/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "f841c5eca8e1ce5413845e79ddd1129d0ae7a04df521066f00d849e149f301bd",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e41c3c0/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "f841c5eca8e1ce5413845e79ddd1129d0ae7a04df521066f00d849e149f301bd",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e41c3c0/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
