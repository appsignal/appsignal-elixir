# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "d704afb"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "56c7cc0e7464f1d8777c0909bba6c4741855af73b8af3a98d494491479575324",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "56c7cc0e7464f1d8777c0909bba6c4741855af73b8af3a98d494491479575324",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "b9ece4e56246971015eb75ca41308325277c35c20173163bc2a6319147f3fcda",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "b9ece4e56246971015eb75ca41308325277c35c20173163bc2a6319147f3fcda",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "b9ece4e56246971015eb75ca41308325277c35c20173163bc2a6319147f3fcda",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "abfbffbf285172d6b4677ac3cbaa94880dbaaee2be6d28326b67cd3c5cb9636e",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "78e0a51e8dc38aeb12791ce597a579aa1eba3060196569614309cc7597c62b03",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "78e0a51e8dc38aeb12791ce597a579aa1eba3060196569614309cc7597c62b03",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "579410e3e41f12dfe367ff6c5e64751ed9b53699ce934f5f02e26f2119e45ef4",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "d8994feae00a5b83736b98f96e4343aed6b5943b71da5d05a5a19edc24d8d485",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "931ed7052cede5efe9cd0b4cbd4ce28ba29dc82dde8a37722d72af9a867037b7",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "8b5aaddfa3e01bd0301d975a1f2ab5525c265267f96159b7fac32686d7d8ec2b",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "8b5aaddfa3e01bd0301d975a1f2ab5525c265267f96159b7fac32686d7d8ec2b",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
