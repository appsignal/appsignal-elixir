defmodule Appsignal.Agent do
  def version, do: "a718022"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "881e9b9e6d0ebbeec44cc2f23f09549a1b8247a76040bf9ddf0a654d29fe6980",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a718022/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "881e9b9e6d0ebbeec44cc2f23f09549a1b8247a76040bf9ddf0a654d29fe6980",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a718022/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "57c489da07bb228c0b75738ecf9122692e81427f7f6abaefe0a54d7ff3156647",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a718022/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "57c489da07bb228c0b75738ecf9122692e81427f7f6abaefe0a54d7ff3156647",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a718022/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "677fbfa4a760125d6c2fb591cdcbcbfae8d876c27eb558c92838c1a75cc597f5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a718022/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "677fbfa4a760125d6c2fb591cdcbcbfae8d876c27eb558c92838c1a75cc597f5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a718022/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "91f135ba34ec0fa23a63275c0d8e2397f20c7a28144cac433e2d0afee5cb7a4c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a718022/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "b6fff942929859cbd7b2040ca8b491cd49948673eff8a7f6d169c41332b81187",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a718022/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "38d3f930a2445651e56eda2aa7c80ccfdad79b84f2c4ea504746e6de853bd521",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a718022/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "38d3f930a2445651e56eda2aa7c80ccfdad79b84f2c4ea504746e6de853bd521",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/a718022/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
