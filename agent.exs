# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "06391fb"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "9bf41c183d94c80e980f57ea2e29d08bae97e8097b5284a2b91a5484bf866f8c",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "9bf41c183d94c80e980f57ea2e29d08bae97e8097b5284a2b91a5484bf866f8c",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "74edd7b97995f3314c10e3d84fc832c1b842c236c331ed4f2f77146ad004d179",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "74edd7b97995f3314c10e3d84fc832c1b842c236c331ed4f2f77146ad004d179",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "74edd7b97995f3314c10e3d84fc832c1b842c236c331ed4f2f77146ad004d179",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "0f2430e637eb77ce2093f021777087e87cb1e7be7c86a53771172696791c4879",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "449ba623aaa1853c2d211bf1e2d3a14e5ae09225a62457cbdbcc0983a5713a52",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "449ba623aaa1853c2d211bf1e2d3a14e5ae09225a62457cbdbcc0983a5713a52",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "394796c0ddeb4881c9f2e6ce82f840e66bcb69e027324f6c04f6671067445fbb",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "673271c8c5fd55053d8a719bcd307f787db4ca4633baf8cf961c442bf1805614",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "e90ca19bf61596be022ba04897e8902b3401add58f351a40a3d3a7af241d0bbb",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "cb45da91c51123859e5ef5cea850460c28d6e77dfa08b90375178d9017162ba8",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "cb45da91c51123859e5ef5cea850460c28d6e77dfa08b90375178d9017162ba8",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
