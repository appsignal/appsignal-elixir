defmodule Appsignal.Agent do
  def version, do: "6ce11c8"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "270f44902bcd278277b4e5de598fd081145a35f09ccdad1bc2511cd83d37c2f7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6ce11c8/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "270f44902bcd278277b4e5de598fd081145a35f09ccdad1bc2511cd83d37c2f7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6ce11c8/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "3b7d7b01650d419a5a4cf08cbf149e60a9fedef2a21f06f48672c86fc6087bcc",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6ce11c8/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "3b7d7b01650d419a5a4cf08cbf149e60a9fedef2a21f06f48672c86fc6087bcc",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6ce11c8/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "c5a0b5f156e94ab9ab763ebd031d002d53b2905d8d5d44eecaecea4f3b757cb5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6ce11c8/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "c5a0b5f156e94ab9ab763ebd031d002d53b2905d8d5d44eecaecea4f3b757cb5",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6ce11c8/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "2c3f49329e6549a0f168238ed771d89f128ce3ac56a3d7f950ba58151fc2e03d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6ce11c8/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "7a148a871f61f697eb921828ef93232574c71e8d0ea79d30cd4e27b4f5609bc2",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6ce11c8/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "5cc8e1702275930e4e1d213ad57b64d892d175b9e84242d757bd23b98ae35d85",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6ce11c8/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "5cc8e1702275930e4e1d213ad57b64d892d175b9e84242d757bd23b98ae35d85",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6ce11c8/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
