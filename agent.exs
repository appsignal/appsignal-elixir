defmodule Appsignal.Agent do
  def version, do: "6a17e01"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "9f902ca73ddffe3881c3d9b548a81b26f8935340160a1094b024386adc45c1cd",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6a17e01/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "9f902ca73ddffe3881c3d9b548a81b26f8935340160a1094b024386adc45c1cd",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6a17e01/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "bac1e88663af82ddc56a457879830517b9868f08ad9584368223c76c02a3669e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6a17e01/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "bac1e88663af82ddc56a457879830517b9868f08ad9584368223c76c02a3669e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6a17e01/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "369f0cefa48d9afac3f8d8af47675c09f4a60ddf2a4c6e4370c7f677484cbf3a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6a17e01/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "369f0cefa48d9afac3f8d8af47675c09f4a60ddf2a4c6e4370c7f677484cbf3a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6a17e01/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "c2b46b2b2e95b4cb9da1e2668b633da8a7f32dc27002e24a50b34429235c4508",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6a17e01/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "65ee84abf3a418a29e47c7511c7f3640d0f132967c0001ef12d20a8888658dee",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6a17e01/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "c3f944c9203d73b2d71c4d3cd22aafadee6d7d00e118d4d9ee745dc29d799cd7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6a17e01/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "c3f944c9203d73b2d71c4d3cd22aafadee6d7d00e118d4d9ee745dc29d799cd7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/6a17e01/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
