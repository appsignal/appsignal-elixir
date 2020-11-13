defmodule Appsignal.Agent do
  def version, do: "20f7d0d"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "4a246fe0c12b87981cadc4e37cebf5c30472d039dbb261e3f7da2275ed91688c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/20f7d0d/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "4a246fe0c12b87981cadc4e37cebf5c30472d039dbb261e3f7da2275ed91688c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/20f7d0d/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "7c52c3debb02c10041f673f0dd8ca5c9491a1830825dcafde3d361499096f7c3",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/20f7d0d/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "7c52c3debb02c10041f673f0dd8ca5c9491a1830825dcafde3d361499096f7c3",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/20f7d0d/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "70606a87811c0f3f1dbed1621cae7178da1fc36db10c49221bec0a6e17909413",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/20f7d0d/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "70606a87811c0f3f1dbed1621cae7178da1fc36db10c49221bec0a6e17909413",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/20f7d0d/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "c5cf88e5ac6b02c5bdf5f6f236300db0307fbcda711f7c62c8aa5edfc81cd616",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/20f7d0d/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "5a53d76b7007038a8f60def5204d5edd4fdfc9c77ba5536007e01206f4f4ff6d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/20f7d0d/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "da94014e9ae510791fe864982aa59dc63e776937f614a1f0ac785e2e2354ac88",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/20f7d0d/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "da94014e9ae510791fe864982aa59dc63e776937f614a1f0ac785e2e2354ac88",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/20f7d0d/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
