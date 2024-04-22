# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.35.2"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "4a01803fae744971e2da08a325acb88a5f79bf44cbde03456652affb91fa0817",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "4a01803fae744971e2da08a325acb88a5f79bf44cbde03456652affb91fa0817",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "c80fa534a0f34d0056102ed5ec21cb558b714b17dc2a91f62fabdb992acc8a54",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "c80fa534a0f34d0056102ed5ec21cb558b714b17dc2a91f62fabdb992acc8a54",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "c80fa534a0f34d0056102ed5ec21cb558b714b17dc2a91f62fabdb992acc8a54",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "71236975f40316d67c2b0e797814d52a49df8c5941375c0aed81c6870d82f299",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "00ab0d029ede31225b2d134cdfab1e2c75e15e96229ef9e89ac14f51b8329988",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "00ab0d029ede31225b2d134cdfab1e2c75e15e96229ef9e89ac14f51b8329988",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "2e96245f692f47ee8fd12cca92b620baf79845ec920fb19b38612dd1cb051961",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "a99ebcdf993cd740dc556de9fba6e7ce1c802704c290c4d8b842cb4dc971473a",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "874542de2899dc7ef6d286f1cb719614877651c6cafc9f5ae73d37d1aa0e61da",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "f30c529ed4fffe4f0668bcb59881061b22050813d9d10acf5a4bf03f4547a51b",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "f30c529ed4fffe4f0668bcb59881061b22050813d9d10acf5a4bf03f4547a51b",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
