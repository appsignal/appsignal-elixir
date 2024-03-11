# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.34.0"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "a6c7f10f8efc09f007306189e8af7a2f5335ffec181f76677fa8548f12b8b774",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "a6c7f10f8efc09f007306189e8af7a2f5335ffec181f76677fa8548f12b8b774",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "3c019c103d86b6d3a60d4da5fe5f9449d9980c6087d0f1494e24f91cd045d1d6",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "3c019c103d86b6d3a60d4da5fe5f9449d9980c6087d0f1494e24f91cd045d1d6",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "3c019c103d86b6d3a60d4da5fe5f9449d9980c6087d0f1494e24f91cd045d1d6",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "6025983af8d38ba9265795f5b384bc78421f0641a93b749d8aa941881c818199",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "99556d16c59053cb79d1fa7b88a60cb6b2881daac9e9e5789546c9799bdef658",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "99556d16c59053cb79d1fa7b88a60cb6b2881daac9e9e5789546c9799bdef658",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "48ace6181571418a8e8236f8180345f8c97ac152953741b0c394019d0bbefb63",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "cb0b388ea1275f8b28547bf79bd127ceaba9b32027426f66eb45de8418a9592d",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "571fc4749c22701a6e9e4c68d1fa9fcad0c443e62c6125c1ef57fb9735d93659",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "5f47f08d1373a6d3e7ee579389a60780508b9a5ae6c69883c8a13a0ae6e09da7",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "5f47f08d1373a6d3e7ee579389a60780508b9a5ae6c69883c8a13a0ae6e09da7",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
