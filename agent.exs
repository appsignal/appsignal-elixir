# DO NOT EDIT
# This is a generated file by the `rake publish` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.36.0"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
      "https://appsignal-agent-releases.global.ssl.fastly.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "6b16bf093a6f0eca2a5344f1085a6a0b6216e2ecf87b2f1f8d2828f06de173d7",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "6b16bf093a6f0eca2a5344f1085a6a0b6216e2ecf87b2f1f8d2828f06de173d7",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "1aaf24c79b4aa6b80c8ef216bf27782e1e4bb489b83ac154fd7df4dcd24f0c82",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "1aaf24c79b4aa6b80c8ef216bf27782e1e4bb489b83ac154fd7df4dcd24f0c82",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "1aaf24c79b4aa6b80c8ef216bf27782e1e4bb489b83ac154fd7df4dcd24f0c82",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "1f933fe27dedc503eaf3d1d42c92ad1c5f2d36e582157db06fbd2e042c770573",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "3ae7f080f4802600b9958651044e9b30e1668d4f1d145c989c378f08d7b930cf",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "3ae7f080f4802600b9958651044e9b30e1668d4f1d145c989c378f08d7b930cf",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "e89a2a31994017310f59239e399cf87662cb28d06d9e054ba513ae30a5b59738",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "56f4d6f3f258d4c202c8a8967f0eccf9da9cb5e93f7f7b5bc0ba40d44bcb1e69",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "b8c8a473556353a28da09910220c4af43e21b89a8c0daac972e04644b3b91c85",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "dd2d49abf3052cf07de88d2a2e7d84ed4ad358d90ac7d9d12362b710b96edb8f",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "dd2d49abf3052cf07de88d2a2e7d84ed4ad358d90ac7d9d12362b710b96edb8f",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
