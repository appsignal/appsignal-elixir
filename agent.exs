# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.35.11"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "a897f48c0e821fc25eb3e3565ba6d88c6830fcd1e9d68f2d363d3a6aea09a5f8",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "a897f48c0e821fc25eb3e3565ba6d88c6830fcd1e9d68f2d363d3a6aea09a5f8",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "ad35cfdb2932c62675c9fa3b7abdd669fdf314133eeb620f4332793ac94d9c54",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "ad35cfdb2932c62675c9fa3b7abdd669fdf314133eeb620f4332793ac94d9c54",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "ad35cfdb2932c62675c9fa3b7abdd669fdf314133eeb620f4332793ac94d9c54",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "32b74d621f202da2eef162f82c4ea4263d8a195b314496207160a997c433bbba",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "7ee9b4f5cbdab32d9d14150c924e1f536c86e71f5b4c765cbb84bcd00cd12c3c",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "7ee9b4f5cbdab32d9d14150c924e1f536c86e71f5b4c765cbb84bcd00cd12c3c",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "9cc4ef840c0ea65dda40eb5693fe3dd07f76f87d44a281c0a633da27f125bd12",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "23b6962812a12c694d8b0ca02cd132b4759de821ea33f8db1cce62a6ddcfd40a",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "ca30a855b4a04702872fd8b5e78d39f2e787eb34e4f75dd1e123db70a38a367f",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "f2729157b59cbe8854c4b0cd82d7c2b060b0691a2cba9991f69c60504db9e3dd",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "f2729157b59cbe8854c4b0cd82d7c2b060b0691a2cba9991f69c60504db9e3dd",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
