# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "f9b0c15"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "a830ab7b7729ecdcf77b79322d0f38f866fc42a96ca569d18923fc60ae212f9e",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "a830ab7b7729ecdcf77b79322d0f38f866fc42a96ca569d18923fc60ae212f9e",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "95b6004d2805e9c89a51bb921dbccf15b1fb0abbbc33ae496a1e1c05349db2af",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "95b6004d2805e9c89a51bb921dbccf15b1fb0abbbc33ae496a1e1c05349db2af",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "95b6004d2805e9c89a51bb921dbccf15b1fb0abbbc33ae496a1e1c05349db2af",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "3f8ff2aa9698520af0a5bef2ab79ec8a97bdda405f7398d33060f4dfbc94fb67",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "5543d922255c4b750fdf5463f941057c5e9812d3c6a71527275cf6b498012c57",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "5543d922255c4b750fdf5463f941057c5e9812d3c6a71527275cf6b498012c57",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "faea43a74e749ac84d0b1b85e065c7eee0694767e8b4f03340fb1b78dce058c4",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "3ee17af45f24d4bc828c958f4fa8fcadc799d5b2d38b44a14e8caec1ce78ffaf",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "d39384cf1deeb47d5ea35addd3ae3f44634cfd3ab034f27e45ed66e09180ba6f",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "f41c97626d8e22797a6a1bda3c01c08b4c1d52b157cd1e7a22aed9f186324c30",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "f41c97626d8e22797a6a1bda3c01c08b4c1d52b157cd1e7a22aed9f186324c30",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
