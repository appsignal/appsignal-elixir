# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.34.2"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "5bf07d396b22fd414eac70c545c710ab60114b1a2fa28aa92f8a5379483fe8fc",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "5bf07d396b22fd414eac70c545c710ab60114b1a2fa28aa92f8a5379483fe8fc",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "6099dfa72394de9e19e8524c19e5292cacd2359a5ceac634c878c113b6f5e875",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "6099dfa72394de9e19e8524c19e5292cacd2359a5ceac634c878c113b6f5e875",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "6099dfa72394de9e19e8524c19e5292cacd2359a5ceac634c878c113b6f5e875",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "34061220065890545627b8988062950a20ab873f297c1e3ba1c1709038c23c96",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "f8285d87fa72717889e89059a64bba7e98c45ecc720e533c2b4fc92c60a30a04",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "f8285d87fa72717889e89059a64bba7e98c45ecc720e533c2b4fc92c60a30a04",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "fd6718fee5638986b77ebd777649f013b52f69f4b1886c41c85626c6f901bcb9",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "561626ac2bf31c6a5af9d21994fe7ca55cc89619b0db0d1f575d311259e99bae",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "03d8464040796f2d242ce66f12297f238d686794a0c2fe4090e0cde1b7bee272",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "422cbc821ac99087ca132aa1ac4290cdf08d6f5b8c24fed18e7d321b1ea8e460",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "422cbc821ac99087ca132aa1ac4290cdf08d6f5b8c24fed18e7d321b1ea8e460",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
