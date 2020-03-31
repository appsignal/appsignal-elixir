defmodule Appsignal.Agent do
  def version, do: "8a74ae1"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "7bd0ec9a83aeb95db5247a3d02517b1237abf6524bf03fad83bdf18e474931b2",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/8a74ae1/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "7bd0ec9a83aeb95db5247a3d02517b1237abf6524bf03fad83bdf18e474931b2",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/8a74ae1/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "3906e5bfd8acac2e4163c6646abc2dc26127a2230b249a21e096f55fd71232f4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/8a74ae1/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "3906e5bfd8acac2e4163c6646abc2dc26127a2230b249a21e096f55fd71232f4",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/8a74ae1/appsignal-i686-linux-all-static.tar.gz"
      },
      "i686-linux-musl" => %{
        checksum: "26f68dbfd957f0c4a416ecb7097f63f6625eb052368e7b40d289dcccac926559",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/8a74ae1/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86-linux-musl" => %{
        checksum: "26f68dbfd957f0c4a416ecb7097f63f6625eb052368e7b40d289dcccac926559",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/8a74ae1/appsignal-i686-linux-musl-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "18a6195f05158af1afad5ccdc2e447ac870937f2a9857b1e66cbfd29b70c0de2",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/8a74ae1/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "7b69951ce265bf1bf1b0ccd8c95b7078117215cc26ab0e29c423306782659830",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/8a74ae1/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "ae28a9efe10ec8d73cc4b61b92b7a0ba8054e5c4165df9dbcd2223a006f27f24",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/8a74ae1/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "ae28a9efe10ec8d73cc4b61b92b7a0ba8054e5c4165df9dbcd2223a006f27f24",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/8a74ae1/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
