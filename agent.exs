defmodule Appsignal.Agent do
  def version, do: "1d8917f"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "777cf5c54eeb32d9d0d6de48c61f14d977244351a4a9e70c9b30c4221e38012c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1d8917f/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "777cf5c54eeb32d9d0d6de48c61f14d977244351a4a9e70c9b30c4221e38012c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1d8917f/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "483417f3afbc76b959d68137717b85d44e9dd14c56bad3a44fd370294dc86273",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1d8917f/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "483417f3afbc76b959d68137717b85d44e9dd14c56bad3a44fd370294dc86273",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1d8917f/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "ad58fec875496aae76c870e5a1abdf37af27e4d237fc791c4820ef8ccfa05586",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1d8917f/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "ad58fec875496aae76c870e5a1abdf37af27e4d237fc791c4820ef8ccfa05586",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1d8917f/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "dcab7852e81cbacb0a187cb62ce2f583f3ff835fb7c49c09f4e41df64b4b81c5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1d8917f/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "63cb4ac3d8befaec47eb907b1ff4c6c4af93e39fd7696db783cb6e656dda297c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1d8917f/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "39c006dd131d1ca452ff79ec988688a69823e0abf26ee6966b1639cc42720416",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1d8917f/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "39c006dd131d1ca452ff79ec988688a69823e0abf26ee6966b1639cc42720416",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/1d8917f/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
