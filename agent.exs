defmodule Appsignal.Agent do
  def version, do: "0318770"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "7b17cb76edc58ea54381455f74934d08efbfb7807007e97ae01f751101da8b50",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "7b17cb76edc58ea54381455f74934d08efbfb7807007e97ae01f751101da8b50",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "d90172492ccf83527696fcd0353796d3d0d4e1704ff986ae90a774a7f11a85a2",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "d90172492ccf83527696fcd0353796d3d0d4e1704ff986ae90a774a7f11a85a2",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "d90172492ccf83527696fcd0353796d3d0d4e1704ff986ae90a774a7f11a85a2",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "bef06f27d98cc1afc30b2d8fa23af69bd0206407b0d8d2f052278de3b8c5f2b5",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "7e0aa277c4e49ebe1b805e9db615544c5488a23d8b439867a2a6357d37c897bc",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "7e0aa277c4e49ebe1b805e9db615544c5488a23d8b439867a2a6357d37c897bc",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "e918e24ff1f86d939b8f571506b11f2890d81c741de56cb06ac81b5dcc3f70e1",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "1a90421519d7860bf41d606866252cc7f1cb828a7efb9622045ee4f04d757ebd",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "22cdd8e44e60dd69003d28ea95c994c27d2223a3872c541c966f32dbea3b0462",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "22cdd8e44e60dd69003d28ea95c994c27d2223a3872c541c966f32dbea3b0462",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
