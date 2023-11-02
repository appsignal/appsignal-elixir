# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "b604345"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "98ac31aa2ca05a18e5eb94a8ecee75b83bb7d973f0f7565a36815b95577aa727",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "98ac31aa2ca05a18e5eb94a8ecee75b83bb7d973f0f7565a36815b95577aa727",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "228810d4d6c344cf6346d889b5eab4d23140a310d4e93465fb2bd461e4e4652e",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "228810d4d6c344cf6346d889b5eab4d23140a310d4e93465fb2bd461e4e4652e",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "228810d4d6c344cf6346d889b5eab4d23140a310d4e93465fb2bd461e4e4652e",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "aa36f82e040b86743fed514268dc1c7d83b14739dd65337a05bf2d994b83a3aa",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "7ce2f5ed5a0f0b4ad574e897d6cd0e5912928b211b307b20b6837c1bcbfaf640",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "7ce2f5ed5a0f0b4ad574e897d6cd0e5912928b211b307b20b6837c1bcbfaf640",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "a597e674a8285871df3c42dc98400a8adff969737d23f8336b10d68a5d70081b",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "ce8e4aa510880f533f17d62c53386ddf8222d2e5cd325b29f53c68661e76eea3",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "2923da7c60ffc78f22c583e4653d904c11254c2ddd030face089b5e22e15ede2",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "59d341ed55ae705f034fbfa0007488e2e4c92c8e8ce0cc20604e467f252c9fd1",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "59d341ed55ae705f034fbfa0007488e2e4c92c8e8ce0cc20604e467f252c9fd1",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
