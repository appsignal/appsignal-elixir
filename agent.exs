# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0d593d5"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "8e63a3b1ee61165914e6dbb8654c1ad7f096079c77d0559c1733dff15103f4ab",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "8e63a3b1ee61165914e6dbb8654c1ad7f096079c77d0559c1733dff15103f4ab",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "cdf323d1b411f45084c13dc4a2c0f980599273d64ab91a28cd07bbc48b3293f6",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "cdf323d1b411f45084c13dc4a2c0f980599273d64ab91a28cd07bbc48b3293f6",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "cdf323d1b411f45084c13dc4a2c0f980599273d64ab91a28cd07bbc48b3293f6",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "a6baf7c586722c71c9d5ec885c8ca17da6b9fc9c5d7ab154a7b667f28d082a0f",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "c102053fe1f68af84d0b362bd892256981bc4a2dec7e12fec27ea57ba0efbda2",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "c102053fe1f68af84d0b362bd892256981bc4a2dec7e12fec27ea57ba0efbda2",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "8f3987d22f0fcbd466377e624aa645c5b9b0f4bbc88855ddb7076b09b9a8d42a",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "e353e165f828cb788c85199adb1b39f15c26406da948117a34b4944f6eabfabc",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "b08c5d65fbff05ac6838aa0ed4614b669701f009826652f7d67ab423fede0e44",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "f516b4c84274b9c56cbcb11c252685a4ef97b68b9fec6c189dde96fd37bbf515",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "f516b4c84274b9c56cbcb11c252685a4ef97b68b9fec6c189dde96fd37bbf515",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
