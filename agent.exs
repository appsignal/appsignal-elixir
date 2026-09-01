# DO NOT EDIT
# This is a generated file by the `rake publish` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.37.0"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
      "https://appsignal-agent-releases.global.ssl.fastly.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "1c05ef4cd4f0d0646bbc00a61568448cafd6c8cd23e152a4d7e22bab7e733cf1",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "1c05ef4cd4f0d0646bbc00a61568448cafd6c8cd23e152a4d7e22bab7e733cf1",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "031d0f3c32302271274d1e602c9cecb2b037e9dd338001901ff4ed4d0e457075",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "031d0f3c32302271274d1e602c9cecb2b037e9dd338001901ff4ed4d0e457075",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "031d0f3c32302271274d1e602c9cecb2b037e9dd338001901ff4ed4d0e457075",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "48499ed06fda433dc7347a4a3d23944d0bfb31604e5d7f52db0a0bbe437f8e03",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "41600ba4171cb8549ff9c8b675e9b4ef100eb7ef0a001a970964af04dc209738",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "41600ba4171cb8549ff9c8b675e9b4ef100eb7ef0a001a970964af04dc209738",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "8240c494573360ad147aa56a973fe809bf1f3976383b8cd990fc0824e5554913",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "39de4602e300f701ed28748bd1c523bedf44f2d0f6241fffe370485185a895cc",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "13fa41ad765a9c79f374dad4d131e7860afb8760c11508af1de982580798a3bc",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "c519b132c7a1de2a8dbb8c36d87fe91b4c0451d2c65d8bd4f44b748bb2ad2904",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "c519b132c7a1de2a8dbb8c36d87fe91b4c0451d2c65d8bd4f44b748bb2ad2904",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
