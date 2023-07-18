# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "32590eb"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "d19ddec878fd1c608bfc44219eee3059676e329575af0a0f9077a6ebd13ab759",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "d19ddec878fd1c608bfc44219eee3059676e329575af0a0f9077a6ebd13ab759",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "ee637a448d7f063a603b34bff2a0387842fd9b7efe477f43c69850d1bde649d8",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "ee637a448d7f063a603b34bff2a0387842fd9b7efe477f43c69850d1bde649d8",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "ee637a448d7f063a603b34bff2a0387842fd9b7efe477f43c69850d1bde649d8",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "c723895a2b627dc9bd6f756468206bb8b946e1ddaeab13f2562d47765bcbdc92",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "7e8e9b0ba5bde6ed3b3c697eb5c92c1840e0ab1a0ecad1e588d684c04f5aad2b",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "7e8e9b0ba5bde6ed3b3c697eb5c92c1840e0ab1a0ecad1e588d684c04f5aad2b",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "b34f064d17a7ab047ebb0eac512452ed4ea91eb7035cd3caa5c06ec8c425ef8e",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "543e47617392cfc243aa053280cd98804ce71728ddd3e38c9b5c6f62a6006b97",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "7e44a1e739f1d4e01fec73cdb4878c0b0b6af5b0f5b433f30807d768fd0cf2f0",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "5ddb4d0d357fbb4677156f538f325924fa53f7fbba5885761b58596fc2ded8ad",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "5ddb4d0d357fbb4677156f538f325924fa53f7fbba5885761b58596fc2ded8ad",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
