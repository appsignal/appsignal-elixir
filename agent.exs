# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "f57e6cb"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "dd1ae8d7897edf3112741381226e3622e91553dede6eeae48ca07aae84ac050d",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "dd1ae8d7897edf3112741381226e3622e91553dede6eeae48ca07aae84ac050d",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "cd5175979ec293d0471c71de1fdd00817bea75f800603a1b87931b19471495f3",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "cd5175979ec293d0471c71de1fdd00817bea75f800603a1b87931b19471495f3",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "cd5175979ec293d0471c71de1fdd00817bea75f800603a1b87931b19471495f3",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "ae899aba4fa260c1aa1d21cc8f2bf379a2b52596ef2979e9b9b70f0cd54872d4",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "3934810379bade5096a5f055450ddd38f60c1bb2fbc05bebcea92f8f7250a81e",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "3934810379bade5096a5f055450ddd38f60c1bb2fbc05bebcea92f8f7250a81e",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "956288a49717ea61ec303ef4ab52e7bfafea6e575a8bb9839df24b947d22d988",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "5f96744692b6b079bd2b97ac6d8d5900123f108a27237664c88a49782b7ba433",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "23ea3fdcc5ae7dfdc85214c872ef928ed702c029b05c059db614583f689b9304",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "23ea3fdcc5ae7dfdc85214c872ef928ed702c029b05c059db614583f689b9304",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
