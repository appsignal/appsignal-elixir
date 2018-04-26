defmodule Appsignal.Agent do
  def version, do: "e8718b8"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "4e8e62f97286783a3a78d5de5939d2c77e965fa2b408a0857680254629f47b82",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e8718b8/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "4e8e62f97286783a3a78d5de5939d2c77e965fa2b408a0857680254629f47b82",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e8718b8/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "899754322392f754bcae57e9fbc8daf3852115b8f08c2617a485a6a747aa2dac",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e8718b8/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "899754322392f754bcae57e9fbc8daf3852115b8f08c2617a485a6a747aa2dac",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e8718b8/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "777626cedb283037379e00dcabc9d9789bc6e6c53609767a3034120c1874ded1",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e8718b8/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "777626cedb283037379e00dcabc9d9789bc6e6c53609767a3034120c1874ded1",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e8718b8/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "729a340523ddfa0a14f2f24eeee723d4f33116b2dcb384875b603e991bddf26b",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e8718b8/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "1634d9f1dd16ea8ed9603cd44071e6b136bf505f953507bcebb9385b5207a00b",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e8718b8/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "06fdaafcd0754efa64a399d91af55186d1038c1dec873e9d6e10a5277faa44ec",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e8718b8/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "06fdaafcd0754efa64a399d91af55186d1038c1dec873e9d6e10a5277faa44ec",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/e8718b8/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
