# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.34.1"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "351f3dae916d3e84177d8cc35eaeaca5345f4deca9e0925a29353915cc0530d2",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "351f3dae916d3e84177d8cc35eaeaca5345f4deca9e0925a29353915cc0530d2",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "fd7359232fbd65f10ee565fcf65f4afa6d7a2ba1a8dead200c34736ca942df16",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "fd7359232fbd65f10ee565fcf65f4afa6d7a2ba1a8dead200c34736ca942df16",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "fd7359232fbd65f10ee565fcf65f4afa6d7a2ba1a8dead200c34736ca942df16",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "dfbab18b7faa24684bf0ab57666b6b493356a3da43ecdba2e992b2d6d513cf31",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "ce4a819f3eaa4590795497915e4a20b3fe281a0821364b80d26ffd1391af67a8",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "ce4a819f3eaa4590795497915e4a20b3fe281a0821364b80d26ffd1391af67a8",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "e55f9ecb4e4b51e9232918216487712b63a7cfea9710763f61077e8d40d53dbe",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "8963ebc98405648205a6d8aa371bafa49cb33cd104e0c3e6cc1856ba41fe3d8c",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "34bb72678b896a2a8289a97611a61a297b5a0e6110f5085a683ad93857cdf26c",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "68e882ba3bc87328953d9bfbb676b00d4199756a7090d5cdc265a4b32d857cc5",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "68e882ba3bc87328953d9bfbb676b00d4199756a7090d5cdc265a4b32d857cc5",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
