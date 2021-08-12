defmodule Appsignal.Agent do
  def version, do: "0f40689"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "a2b46f8b5446a95878a023e1f5a0b8aaefc04f3fdd14875edc6cd0ae0c1bc6ca",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0f40689/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "a2b46f8b5446a95878a023e1f5a0b8aaefc04f3fdd14875edc6cd0ae0c1bc6ca",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0f40689/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "f5dced4eb1064cfe3a080164859bdb5cb7dc316c95c8ca606fb4dd3dae441020",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0f40689/appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "f5dced4eb1064cfe3a080164859bdb5cb7dc316c95c8ca606fb4dd3dae441020",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0f40689/appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "f5dced4eb1064cfe3a080164859bdb5cb7dc316c95c8ca606fb4dd3dae441020",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0f40689/appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "db2242050c5b99a6eb6aaafbb571f65e4a5ac08a08c25a009f992d8240864b27",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0f40689/appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "6f952674ef7c0d7444c69991619e75bd244232b009617491d09b3f58a2939c9a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0f40689/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "6f952674ef7c0d7444c69991619e75bd244232b009617491d09b3f58a2939c9a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0f40689/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "85a719387ea6052f50396f932d924efb8b572face63d9f3610c72aeeb4c75e9e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0f40689/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "221add79e8216bf21c98af54c6eb0010c7b0cc77e7f8690e260c6d8e0e8d763d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0f40689/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "5d28a24eecc59cab62ecfce460ac83a4f783556efe060dccc740c5c651edb728",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0f40689/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "5d28a24eecc59cab62ecfce460ac83a4f783556efe060dccc740c5c651edb728",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/0f40689/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
