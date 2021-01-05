defmodule Appsignal.Agent do
  def version, do: "44e4d97"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "24039f3e9febf1a7e94f55e4b2b90f1acb498efd14e83d944f992aea54bb8b02",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/44e4d97/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "24039f3e9febf1a7e94f55e4b2b90f1acb498efd14e83d944f992aea54bb8b02",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/44e4d97/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "11c627b56bb2f431c6490329b2cdec66ee26dfeb7ec63ddf5898bb3fde0ed75f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/44e4d97/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "11c627b56bb2f431c6490329b2cdec66ee26dfeb7ec63ddf5898bb3fde0ed75f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/44e4d97/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "4507f7de6a3ea2394029fee001dbec0763c69cfb613b881dfb91ab0f80d7aaa9",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/44e4d97/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "88ad5d6c9d7b5fadd7448795dd388f48012034b3062ad048d93499ee3488725f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/44e4d97/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "7237f4e0fe1140c53b344399a04b85310274ef638ee61d16f2b1f3c271968519",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/44e4d97/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "7237f4e0fe1140c53b344399a04b85310274ef638ee61d16f2b1f3c271968519",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/44e4d97/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
