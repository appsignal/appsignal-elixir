# DO NOT EDIT
# This is a generated file by the `rake publish` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "0.37.3"

  def mirrors do
    [
      "https://d135dj0rjqvssy.cloudfront.net",
      "https://appsignal-agent-releases.global.ssl.fastly.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "283afa4ec2222108c994cf3c943357f649a9e09a200c0b3b06d33b9fefa8487f",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "283afa4ec2222108c994cf3c943357f649a9e09a200c0b3b06d33b9fefa8487f",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "201b0d402c8685492899ba5cbd4d1ff3d6389d0b5fe2cc5ff62cd9a1f4a57f19",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "201b0d402c8685492899ba5cbd4d1ff3d6389d0b5fe2cc5ff62cd9a1f4a57f19",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "201b0d402c8685492899ba5cbd4d1ff3d6389d0b5fe2cc5ff62cd9a1f4a57f19",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "f8e67ca70c013908d0d5b1b0a78aa67be59f5bb885590ab6c70b0f2bc4d9148c",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "c52333b87c6da6b2b979097c07d13925104b5d535e6287babc71566c3fdcf321",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "c52333b87c6da6b2b979097c07d13925104b5d535e6287babc71566c3fdcf321",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "5d2816036d1025eecc7005114780120788c0a76ff899740ebaa54f063aff7a18",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "937e4517d435898518a0b529196160682172c1eec32e6ab31ad9b4e7220705fe",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "fd9abfd9320bf893aed80d9487aab2e5da0af33c48e6c54a284f87c1a00c9af3",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "e79ecb04aabb439e1b0aaa829dddec01886758843f3e29a46d8922688719af26",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "e79ecb04aabb439e1b0aaa829dddec01886758843f3e29a46d8922688719af26",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
