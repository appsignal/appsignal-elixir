# DO NOT EDIT
# This is a generated file by the `rake publish` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.36.5"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
      "https://appsignal-agent-releases.global.ssl.fastly.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "174222cc211a50eefa35f1b2391f94ea1a0fede07ab4210f90764ea4353e24f7",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "174222cc211a50eefa35f1b2391f94ea1a0fede07ab4210f90764ea4353e24f7",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "54d9687a716c5e607f92aa93782b1c64fe064d4a42c58473e0b07eb313378103",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "54d9687a716c5e607f92aa93782b1c64fe064d4a42c58473e0b07eb313378103",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "54d9687a716c5e607f92aa93782b1c64fe064d4a42c58473e0b07eb313378103",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "59746a7fe722eb9c985e155aeaefdab37d96a96f650eff81b8610955b09edebb",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "4202807069dcd2b9df2c478273f7ce23f88e47224e75a5062592ed6af8a675ec",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "4202807069dcd2b9df2c478273f7ce23f88e47224e75a5062592ed6af8a675ec",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "948ae7a80b5c33807ddfd7f7e575515db76868dc4750993e658a19920db43d99",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "e9d717aecfe1a7bcc139289b8aa10d3e4e52f487776cd1a26025ac13b55b7754",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "313affebfe45a3d31a368e39cb3f1ea3860de21282c52ad97c0d194a9dbd52e8",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "b35d43501b22bf9a98fc37545932fe79c4adee3cea7c4b5a677266a858ceab88",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "b35d43501b22bf9a98fc37545932fe79c4adee3cea7c4b5a677266a858ceab88",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
