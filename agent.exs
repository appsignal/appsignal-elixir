# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "8d042e2"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "e0142859f35e31b52dcc57418636c05bcb21940ad499bbe255f90a1cf7359bf7",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "e0142859f35e31b52dcc57418636c05bcb21940ad499bbe255f90a1cf7359bf7",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "5a1ab02452497b29222d580f3e9d3649eb547b8c90338858462d4f221dd18ff9",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "5a1ab02452497b29222d580f3e9d3649eb547b8c90338858462d4f221dd18ff9",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "5a1ab02452497b29222d580f3e9d3649eb547b8c90338858462d4f221dd18ff9",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "0e85a0a13b9457c4ee1f316e92e8d95de9125bbaff90ceb826bcefaaffa413d9",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "0e8a0490ca960bb8e57183156ed4999afbd70cf13c640fe96f9b0e25556075f1",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "0e8a0490ca960bb8e57183156ed4999afbd70cf13c640fe96f9b0e25556075f1",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "4eec193edeae76e0793789846112ac9127870c90a8ae6e47aa2a8490163733aa",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "d91d1ed6e775cc00319fca0a4144dff064d31fb6a8a28dbb5027add44e4dab02",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "0ff6702bd976871f610f39ff6c2dd73c4535b12c15c81c0d0afab7650e75922d",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "d973edc7f13cdad2993c415f17a680a4de3288ce57fc5ae0c69ef3a1ccbb2856",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "d973edc7f13cdad2993c415f17a680a4de3288ce57fc5ae0c69ef3a1ccbb2856",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
