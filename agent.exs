defmodule Appsignal.Agent do
  def version, do: "1bd6660"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "77371d3bc0a2933755ad637d5fad4b5695b7c509335a36d91c367e7de226a9c5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1bd6660/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "77371d3bc0a2933755ad637d5fad4b5695b7c509335a36d91c367e7de226a9c5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1bd6660/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "f256cda20f7b614d5286645257bf3d6861a106251c9c9ff009aa49582fc59231",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1bd6660/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "f256cda20f7b614d5286645257bf3d6861a106251c9c9ff009aa49582fc59231",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1bd6660/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "f6290a6ccd8a700af66720fa5e99a99265c3f76f64fb841919a7ce061b04e7cc",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1bd6660/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "f6290a6ccd8a700af66720fa5e99a99265c3f76f64fb841919a7ce061b04e7cc",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1bd6660/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "e2e91a85296bd68718e59cc72a27a224b399bd87ca309e562d1b27cc408c6c40",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1bd6660/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "dff3eebc7bc3453984e1c58d8f11ae28fbf352561f44946cd1b381387c499a5a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1bd6660/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "27806c713ce7d594cf32bc290cc2aafdbbd604a2ee9b6edee7d19e8adb029792",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1bd6660/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "27806c713ce7d594cf32bc290cc2aafdbbd604a2ee9b6edee7d19e8adb029792",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1bd6660/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
