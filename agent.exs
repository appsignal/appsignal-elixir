defmodule Appsignal.Agent do
  def version, do: "94aaf32"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "1316f7c202a232ae691dc3745f2ec6ee824e01aa2a613e56a41979b19ba1ec8f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/94aaf32/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "1316f7c202a232ae691dc3745f2ec6ee824e01aa2a613e56a41979b19ba1ec8f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/94aaf32/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "c0c5c3ad646e500c2a4a78afadbf4828560e4b4f00901a726fd06af0e5047cdc",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/94aaf32/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "c0c5c3ad646e500c2a4a78afadbf4828560e4b4f00901a726fd06af0e5047cdc",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/94aaf32/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "05bfaa688ceef363523818b2d0d5d94db178b2596cca96d804932c129d8ede10",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/94aaf32/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "05bfaa688ceef363523818b2d0d5d94db178b2596cca96d804932c129d8ede10",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/94aaf32/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "db176c740e26db37d61df1f9e18d57127a1a5208495f02bf18ff2c9553b12d62",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/94aaf32/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "a3c5882bfa3ee6f9612449a8c90eb64791764f34d910c21fd436ce26cf232b4e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/94aaf32/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "ba8e6b26b76809a22753a6e6829be72c45a1c2a31c113e04d0fe09789ff63d98",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/94aaf32/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "ba8e6b26b76809a22753a6e6829be72c45a1c2a31c113e04d0fe09789ff63d98",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/94aaf32/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
