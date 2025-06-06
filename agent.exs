# DO NOT EDIT
# This is a generated file by the `rake publish` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.36.6"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
      "https://appsignal-agent-releases.global.ssl.fastly.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "b4a9453064663f969f2012d0fbbfad4566a35f3231d92d05c46b0e4fd15e62de",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "b4a9453064663f969f2012d0fbbfad4566a35f3231d92d05c46b0e4fd15e62de",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "fc1245fca1445c2eb25f9e4f0dd5809f86eefa7e96ea87a227891ce76af81bfc",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "fc1245fca1445c2eb25f9e4f0dd5809f86eefa7e96ea87a227891ce76af81bfc",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "fc1245fca1445c2eb25f9e4f0dd5809f86eefa7e96ea87a227891ce76af81bfc",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "41f69ec7e2d15a552897eb22a745fb6df2589d8b53909155c16bd5fe5d830c71",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "abdaeca2c16362838ad0c81a36f55ae05638b9bc4cee647928e5c07c56582f6d",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "abdaeca2c16362838ad0c81a36f55ae05638b9bc4cee647928e5c07c56582f6d",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "ca8bf1da8e0477027000ecad7b224244d3ff3217fa90652841567aa76bb0e2dc",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "dd9ea02fe7c0521a9761d94b232dd91d4fb2d39e73955872eb7b8344926d439d",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "dab51a719c468faa87232fd4c1c5ea1ad43a3ec0fcade99cafe1d82b039e3708",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "115abdd9452f37037e7cc1f0e5b205e00317142a1d1d31d84c5729e6fba3cd46",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "115abdd9452f37037e7cc1f0e5b205e00317142a1d1d31d84c5729e6fba3cd46",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
