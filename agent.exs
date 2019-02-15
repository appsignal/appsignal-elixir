defmodule Appsignal.Agent do
  def version, do: "6f74473"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "b97f65dbc21a12ddaeb3c84b69bf1d9d31143f6e094ad4a1c36d09ba35e824a1",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6f74473/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "b97f65dbc21a12ddaeb3c84b69bf1d9d31143f6e094ad4a1c36d09ba35e824a1",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6f74473/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "7d48b936ff3a5da2a2b92dc55e3666ba80bcbf25ce65b8f496829c26822e2bec",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6f74473/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "7d48b936ff3a5da2a2b92dc55e3666ba80bcbf25ce65b8f496829c26822e2bec",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6f74473/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "fe29178c35e474515d39515e634ea9d24b79a86bb5d1c583482da03347ce4e88",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6f74473/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "fe29178c35e474515d39515e634ea9d24b79a86bb5d1c583482da03347ce4e88",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6f74473/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "0642d2616413bef8b607b63f0ac79d64b515b752c782e1bd7c3ff0b4198f3f23",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6f74473/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "de0da8e59c45710bbf274ec600cd229863965e023f98388ff59edaa4a969e344",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6f74473/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "67814be3779bb06d7ef96fc53eba416a488c8707967112f453c26eee86fe165c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6f74473/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "67814be3779bb06d7ef96fc53eba416a488c8707967112f453c26eee86fe165c",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6f74473/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
