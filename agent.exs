defmodule Appsignal.Agent do
  def version, do: "f9d2b57"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "96b144b211525c83e29dc4c337f4addee3f168ffd82de7256f551d30c538445c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f9d2b57/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "96b144b211525c83e29dc4c337f4addee3f168ffd82de7256f551d30c538445c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f9d2b57/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "0f58d7ab6c430c42d4b2b6ca31a029654a79022f4752f053364e9862efcce43f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f9d2b57/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "0f58d7ab6c430c42d4b2b6ca31a029654a79022f4752f053364e9862efcce43f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f9d2b57/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "131d8eac0bb9b0640f670834b136fbea581d9f96a31299e18ca4b7450a95df6d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f9d2b57/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "c8f5e866b7c9786fc24e198125e71239ef0cffe829dcda9a40c8aab5205db3d0",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f9d2b57/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "9c30322a2685ac246380cc4dab6e24b2fd3d7a42fffaf12c901e2c2a9e7bc741",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f9d2b57/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "9c30322a2685ac246380cc4dab6e24b2fd3d7a42fffaf12c901e2c2a9e7bc741",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/f9d2b57/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
