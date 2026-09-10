# DO NOT EDIT
# This is a generated file by the `rake publish` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.37.1"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
      "https://appsignal-agent-releases.global.ssl.fastly.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "a29834f6a305a0baedbf5bd3f25c28feca45b3a175029d655ece7224515c206a",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "a29834f6a305a0baedbf5bd3f25c28feca45b3a175029d655ece7224515c206a",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "53198c2f10fb56565ceece6632ec0cd38f30e7fef3df79094f11381f4b07f8a6",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "53198c2f10fb56565ceece6632ec0cd38f30e7fef3df79094f11381f4b07f8a6",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "53198c2f10fb56565ceece6632ec0cd38f30e7fef3df79094f11381f4b07f8a6",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "64fc4b0b48d780eb6721421a4d2ef3e4b94ee763266ad5a2768acdf3d9feadd7",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "ea6544e43502d0ec49a708343483244a5ec457ae4c89752a295b238c3e62440c",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "ea6544e43502d0ec49a708343483244a5ec457ae4c89752a295b238c3e62440c",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "bc04fc8691b8950d20776646117fd7a217a3267d4eac14b2c5f446ed8f9fcf99",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "5cd6d3f106d6e34ad6558d5191241860345dfd3e0ad9daaa798c0781e17c142a",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "86c3c6356cac89c4030e427915c3aad7ea804278835bd4a5cc75ebbdd18f5dbd",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "0428134ff69b924900b4cda8d16b181870ef4eced5cb501e9ac2a952f9c52580",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "0428134ff69b924900b4cda8d16b181870ef4eced5cb501e9ac2a952f9c52580",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
