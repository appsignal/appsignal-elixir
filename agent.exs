# DO NOT EDIT
# This is a generated file by the `rake publish` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.37.2"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
      "https://appsignal-agent-releases.global.ssl.fastly.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "04acbec47f4f5955ff51295aa3f3e727c89a42fcfc99ac572225ec4285ee21ed",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "04acbec47f4f5955ff51295aa3f3e727c89a42fcfc99ac572225ec4285ee21ed",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "330cd3d0b0c316ac4cbdfb237930a29e67205c12d5bf7bb1da51213eea97f18f",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "330cd3d0b0c316ac4cbdfb237930a29e67205c12d5bf7bb1da51213eea97f18f",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "330cd3d0b0c316ac4cbdfb237930a29e67205c12d5bf7bb1da51213eea97f18f",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "174eba16ca19747fc9c68acae722d65d194c90a9ba9fbdb51741d770b42ddb6d",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "0da7b25472e1bf40516c9257f5507cbf2024db7c4aff796528ac114bd409d059",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "0da7b25472e1bf40516c9257f5507cbf2024db7c4aff796528ac114bd409d059",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "43ae7bd5492990fcec90d08ab37e5a1ec9cca3f148f93d91a4c8b31b6accdf50",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "a1cf987b2f29548071c7ee6a222158d67ab1451976d5db4b999e5e7156ce10f2",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "43b1e51d848a98cb9bbd1db32105369e103eaeae2ade9b365de5218af1f72c97",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "fe7011fc6874a8a9bd32bd24c4029f41261fbcfcabad400a758da0e4129c0b58",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "fe7011fc6874a8a9bd32bd24c4029f41261fbcfcabad400a758da0e4129c0b58",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
