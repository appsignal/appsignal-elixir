# DO NOT EDIT
# This is a generated file by the `rake ship` family of tasks in the
# appsignal-agent repository.
# Modifications to this file will be overwritten with the next agent release.

defmodule Appsignal.Agent do
  def version, do: "aa4daed"

  def mirrors do
    [
      "https://appsignal-agent-releases.global.ssl.fastly.net",
      "https://d135dj0rjqvssy.cloudfront.net",
    ]
  end

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "8216a8c083ffb7f286fd249c82fb63fe45527276a8a616c0921da3f3e8b9073a",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "8216a8c083ffb7f286fd249c82fb63fe45527276a8a616c0921da3f3e8b9073a",
        filename: "appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-darwin" => %{
        checksum: "5f1782b53f24e2d8f8e0681eb7934af93532f84475c44b7389b2fe88ac34630d",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm64-darwin" => %{
        checksum: "5f1782b53f24e2d8f8e0681eb7934af93532f84475c44b7389b2fe88ac34630d",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "arm-darwin" => %{
        checksum: "5f1782b53f24e2d8f8e0681eb7934af93532f84475c44b7389b2fe88ac34630d",
        filename: "appsignal-aarch64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "0743450b2ad48971ec3251565898e33b9af214b4d2db36e12b7089ff3d3b8f3e",
        filename: "appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "32a72c3a9745348251fe20e8e8d10f52476e8cec47ea3b2495c14d1ca4a30ac5",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "32a72c3a9745348251fe20e8e8d10f52476e8cec47ea3b2495c14d1ca4a30ac5",
        filename: "appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "8804bdd137e87576f0f32e565ecafc395da118e1d427155c38f27cc7d222777d",
        filename: "appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "09f97d946a7d1c45f24824e8c0c296ac49fdbf0a8e9869e45176838bc82929c5",
        filename: "appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "aarch64-linux-musl" => %{
        checksum: "e0f942c8053e2939cffce722c35160d8798d867d91902b6cb9b6ccf7513d0059",
        filename: "appsignal-aarch64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "c105e18399df06884983ec58602a848369a98806ba8264e6dc2b7a06476dd582",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "c105e18399df06884983ec58602a848369a98806ba8264e6dc2b7a06476dd582",
        filename: "appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
