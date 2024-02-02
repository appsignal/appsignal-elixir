# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.32.0"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "73a8a20a51fa87b660065546f10d8d9796d0973b2c57cd41728384fc8c4c02e1",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "73a8a20a51fa87b660065546f10d8d9796d0973b2c57cd41728384fc8c4c02e1",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "f03540f445c8d683310eecf1687feae5c81d23525b71ab7e4f18401c1cbea256",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "f03540f445c8d683310eecf1687feae5c81d23525b71ab7e4f18401c1cbea256",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "f03540f445c8d683310eecf1687feae5c81d23525b71ab7e4f18401c1cbea256",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "7efae5e2a6bc1eec72218c8452d2f0199d6b1575eca79c3c3aae033ccac1de1b",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "e49e89f6a49c117bdfd2f72633b3198c9e42da9cc285c9f07e3d8f5034b1d61a",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "e49e89f6a49c117bdfd2f72633b3198c9e42da9cc285c9f07e3d8f5034b1d61a",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "380efdc2a9925384aa6b8d0d486a81227442ec24a7ab6be956ad070c1bb0aa19",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "d23f81b77eaa734ead0bf168ea503db25b4892ab2f6502ade27876615ce340d9",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "c9ac4b427c8aa5440de166c228d841a93975a495acdd12c1ba357bd4c2b5de79",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "aef6355263fdb004fd128f78fc4e6ec9f5d8528a0fdc76e94785519eb01aefd8",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "aef6355263fdb004fd128f78fc4e6ec9f5d8528a0fdc76e94785519eb01aefd8",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
