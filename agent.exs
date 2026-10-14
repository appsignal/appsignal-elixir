# DO NOT EDIT
# This is a generated file by the `rake publish` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.37.5"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
      "https://appsignal-agent-releases.global.ssl.fastly.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "0c5f9fd85bf0a2468862c8a591e40120e346cee18f2240a46b7bcce0d880ea84",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "0c5f9fd85bf0a2468862c8a591e40120e346cee18f2240a46b7bcce0d880ea84",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "844b7e189522b5ffee6370e5dbff2a687de5b4c2e34f67a638290a2e40dd0ec3",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "844b7e189522b5ffee6370e5dbff2a687de5b4c2e34f67a638290a2e40dd0ec3",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "844b7e189522b5ffee6370e5dbff2a687de5b4c2e34f67a638290a2e40dd0ec3",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "3644566bc411f8f4c9937e53eccdd7bbea4545ddcc8a93db0158c6174f21a399",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "29d534d174d955e0d86c572f1e9ce0ee7c9d9baa98d9f472ff501a79d1bc7dbd",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "29d534d174d955e0d86c572f1e9ce0ee7c9d9baa98d9f472ff501a79d1bc7dbd",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "ba12a448ba337bfecf2a8dd2e67804f273c460973a2f191c87e26e612b7edb7c",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "4331b313e952e2e54a8d217b08f2ff9d704a5581935617e1bfaff20f0680caef",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "364cc397eddf43049c87fc87a385d9cbc7722cdd11ffa2f5052c24e19e0e5d69",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "f1ece6d2f2b0a36a86a4a48059deea89b3ae909c0aafc659372127f072d036ec",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "f1ece6d2f2b0a36a86a4a48059deea89b3ae909c0aafc659372127f072d036ec",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
