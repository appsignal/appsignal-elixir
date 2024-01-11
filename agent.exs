# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "bfe19b1"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "0985697683dc7f2bc0a353b637e3923a79b1945f730deceba73f65807cdcbb16",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "0985697683dc7f2bc0a353b637e3923a79b1945f730deceba73f65807cdcbb16",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "8fe7adac3f265d47f9bff244b357b11551065c15542e22c5e5a10afa7d3d18f9",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "8fe7adac3f265d47f9bff244b357b11551065c15542e22c5e5a10afa7d3d18f9",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "8fe7adac3f265d47f9bff244b357b11551065c15542e22c5e5a10afa7d3d18f9",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "8278a46232ab0b88dfbd5276a7253f147a950ea0f55ebb104ef825a528d24b73",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "2b0cfc65ccd05d1258719e73fc19323729100d02a33d936ba79bb12cdede3763",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "2b0cfc65ccd05d1258719e73fc19323729100d02a33d936ba79bb12cdede3763",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "10bafbef6445ea1a37529b34fb103dd48e185f61f19f58f573377127d03f6a60",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "fba0b10a3dcac0854cd9d19773ab48649fc79a35261eacdfe28d6e70c267b98a",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "98e8aafa0f688b1f1a9c37daf9e9cc1e36edc7e0ad65f86d8402469d15b6a1d6",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "09ebc6406d81fdf81b2e76bef6c1344f34292e1b3727f7fc984c8df5c7698db5",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "09ebc6406d81fdf81b2e76bef6c1344f34292e1b3727f7fc984c8df5c7698db5",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
