defmodule Appsignal.Agent do
  def version, do: "c55fb2c"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "fd287b7efa38d821331d75f4a8d4dd0585f1fc01993406e2c5ebf224d13ac178",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c55fb2c/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "fd287b7efa38d821331d75f4a8d4dd0585f1fc01993406e2c5ebf224d13ac178",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c55fb2c/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "c6c0a54524d1b4483aee03677e32969ca896d1a5561e12d9cb3e45fb5c2deeb6",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c55fb2c/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "c6c0a54524d1b4483aee03677e32969ca896d1a5561e12d9cb3e45fb5c2deeb6",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c55fb2c/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "b60e7514677a0622dbd093b75a353a547661734202dbc76c36842848f90f0461",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c55fb2c/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "69dd6789e1e13177e2e9827a6f1a93d7557cc66d3f4f58a843d46f6d7741eab9",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c55fb2c/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "6a669fe6a894558c83c780f32fb886f4100e1775dcfd490523420c569f315416",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c55fb2c/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "6a669fe6a894558c83c780f32fb886f4100e1775dcfd490523420c569f315416",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/c55fb2c/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
