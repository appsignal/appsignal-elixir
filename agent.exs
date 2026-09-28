# DO NOT EDIT
# This is a generated file by the `rake publish` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.37.4"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
      "https://appsignal-agent-releases.global.ssl.fastly.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "1357165dea876f16db0d808ae6a55bf525fe467b7508074ac6af4bd05b09c4ec",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "1357165dea876f16db0d808ae6a55bf525fe467b7508074ac6af4bd05b09c4ec",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "8e3a75802935cb6e4b236c3fc71229f3f580f6aa678aba29203370aeb17fe14a",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "8e3a75802935cb6e4b236c3fc71229f3f580f6aa678aba29203370aeb17fe14a",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "8e3a75802935cb6e4b236c3fc71229f3f580f6aa678aba29203370aeb17fe14a",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "7bd5d09188de94278bd9770e6903d3834315e67804adb3be554c52a145db2604",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "77c1020cf0b8860f08a5854f386eae59922ea866fb6f5b0ca5c296f27cba1741",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "77c1020cf0b8860f08a5854f386eae59922ea866fb6f5b0ca5c296f27cba1741",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "2424dbd9f3a93ca2f743d60f04669d21ae51878297b167b01589c415ef0c5b4b",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "015dea50026bc966baad007509bcf90e246ed1e5b32c6e23738924e2fc3d8859",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "e4f9cc271c9fb921dbd5a21715216cee3cea2722976296e18fe07a70bb86fa19",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "611b64cd011131326850604092f0d1fd05914353b462a4be84f0d3b4c17991ef",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "611b64cd011131326850604092f0d1fd05914353b462a4be84f0d3b4c17991ef",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
