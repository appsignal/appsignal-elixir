# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "6bec691"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "bef6b987040f2d5feb8d4e2d9483bfa89c75b709a1b9a297b4b736643b488c6a",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "bef6b987040f2d5feb8d4e2d9483bfa89c75b709a1b9a297b4b736643b488c6a",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "ff083420f6ac000d2791800ba641ee331ac8757e298939879ea6f35d35eea80b",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "ff083420f6ac000d2791800ba641ee331ac8757e298939879ea6f35d35eea80b",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "ff083420f6ac000d2791800ba641ee331ac8757e298939879ea6f35d35eea80b",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "755e1721befe259d4b13d914020ea7793399c1dc7abdce1e6695128f30e8670d",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "2590d6ecb89242849ea7bd0923b074520fcf370c360095d2b25f2ea7a8f8e310",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "2590d6ecb89242849ea7bd0923b074520fcf370c360095d2b25f2ea7a8f8e310",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "54b033f215d84fbe819092a553e4921c77a2f686f9924f336c8312cb9efd1d57",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "3c161e852b44e2f0ad1ccd849150255fc0ce39c3b0895fb003c403de12ced331",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "bed2cb1dc599528ac4bc1939da41900f4651013bc97433f2d1c2e6864acb6b7e",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "19b885bccb30a4209608ac1ac3ecaf07f1cd8e78c95dbdb94df51f73360c01bb",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "19b885bccb30a4209608ac1ac3ecaf07f1cd8e78c95dbdb94df51f73360c01bb",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
