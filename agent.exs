# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.35.19"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "0d465ca77500f7e9675d262a5ccd277fc3428821ac96f973b9941ad49a300ea9",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "0d465ca77500f7e9675d262a5ccd277fc3428821ac96f973b9941ad49a300ea9",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "7c735e7490d9d5313e76a0e0508f85983c98caceb0507afa3d8d34bb3b740627",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "7c735e7490d9d5313e76a0e0508f85983c98caceb0507afa3d8d34bb3b740627",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "7c735e7490d9d5313e76a0e0508f85983c98caceb0507afa3d8d34bb3b740627",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "6ed44186487547614b1a2d4f1c2fea4676f2b5829c8949ad86ca61a66db716e7",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "608b8de770ddc9cbc9cae16f793c630079d640b3b77f3af2f854de474e8ef5de",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "608b8de770ddc9cbc9cae16f793c630079d640b3b77f3af2f854de474e8ef5de",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "4499818ce89075c7754e26c8915b452352a155619f2ce648232fad6480638f34",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "ed3a557d8ae6aeb15597ff40dce3739c350053a24d163ddc362af20e7e9d4e1c",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "f18731c7c549cf635ec8b040c3dbd3cdc3285f0e240c2790a8c8003e0ff7cbee",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "fa2c007ca5cb40ac75b7c147d18460edcb0d948648286debc03d4f5afda469f1",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "fa2c007ca5cb40ac75b7c147d18460edcb0d948648286debc03d4f5afda469f1",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
