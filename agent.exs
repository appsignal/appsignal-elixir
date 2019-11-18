defmodule Appsignal.Agent do
  def version, do: "c348132"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "cb287c8e2072fe5b8cf14449bd6892989c392d0c651ce339895ae0302cb69785",
        download_url:
          "https://appsignal-agent-releases.global.ssl.fastly.net/c348132/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "cb287c8e2072fe5b8cf14449bd6892989c392d0c651ce339895ae0302cb69785",
        download_url:
          "https://appsignal-agent-releases.global.ssl.fastly.net/c348132/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "2c3bcd102592bf38fbdb27e7c70502dccbe54a0dc2739a9d54aaa694fcfb41fb",
        download_url:
          "https://appsignal-agent-releases.global.ssl.fastly.net/c348132/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "2c3bcd102592bf38fbdb27e7c70502dccbe54a0dc2739a9d54aaa694fcfb41fb",
        download_url:
          "https://appsignal-agent-releases.global.ssl.fastly.net/c348132/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "0add9eed4452feda7fc5e1bbd0acdff32c353e4ea0b5d527959df57deb1bdcb2",
        download_url:
          "https://appsignal-agent-releases.global.ssl.fastly.net/c348132/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "0add9eed4452feda7fc5e1bbd0acdff32c353e4ea0b5d527959df57deb1bdcb2",
        download_url:
          "https://appsignal-agent-releases.global.ssl.fastly.net/c348132/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "d11221c127c00128da16b419c503281407e429c0ea6f5bfe1691640b8e995e4e",
        download_url:
          "https://appsignal-agent-releases.global.ssl.fastly.net/c348132/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "7ce44dc23c578933ca37a79d244bc367fdc2438408c2a61558adb92bcfebb1fa",
        download_url:
          "https://appsignal-agent-releases.global.ssl.fastly.net/c348132/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "df5f8b61e6ecca40f349cf5c83d5f37f031850d367793dee90dc56f13974431d",
        download_url:
          "https://appsignal-agent-releases.global.ssl.fastly.net/c348132/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "df5f8b61e6ecca40f349cf5c83d5f37f031850d367793dee90dc56f13974431d",
        download_url:
          "https://appsignal-agent-releases.global.ssl.fastly.net/c348132/appsignal-x86_64-freebsd-all-static.tar.gz"
      }
    }
  end
end
