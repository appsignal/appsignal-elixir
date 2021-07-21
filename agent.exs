defmodule Appsignal.Agent do
  def version, do: "271250f"

  def triples do
    %{
      "x86_64-darwin" => %{
        checksum: "059d8c23209aae12da3fdf2b6e7609eda15412365a7e29f426fd7db8d677664e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/271250f/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "universal-darwin" => %{
        checksum: "059d8c23209aae12da3fdf2b6e7609eda15412365a7e29f426fd7db8d677664e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/271250f/appsignal-x86_64-darwin-all-static.tar.gz"
      },
      "aarch64-linux" => %{
        checksum: "cb269522a2b360bfa0c487a69972b1b2baf289f4becbb53c8387d25a2c8cc31e",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/271250f/appsignal-aarch64-linux-all-static.tar.gz"
      },
      "i686-linux" => %{
        checksum: "a5c887b7d4c8a56daf0c56b9a97c63e43c18b8fef3abca019c60ddadeaffb4d7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/271250f/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86-linux" => %{
        checksum: "a5c887b7d4c8a56daf0c56b9a97c63e43c18b8fef3abca019c60ddadeaffb4d7",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/271250f/appsignal-i686-linux-all-static.tar.gz"
      },
      "x86_64-linux" => %{
        checksum: "840f5b06c5f300a3ddf9b61c6acc51d6148ba26464d1652356edc79cf218e200",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/271250f/appsignal-x86_64-linux-all-static.tar.gz"
      },
      "x86_64-linux-musl" => %{
        checksum: "b8d0ae2183abcdb0d05cde1836d932f5d3931f16d28cbfdcae83b79c374bb4d0",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/271250f/appsignal-x86_64-linux-musl-all-static.tar.gz"
      },
      "x86_64-freebsd" => %{
        checksum: "d7937f8eb28bb6cda7d0ab4fb14aa8f98f11e237d753adb327ebee755e80da2f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/271250f/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
      "amd64-freebsd" => %{
        checksum: "d7937f8eb28bb6cda7d0ab4fb14aa8f98f11e237d753adb327ebee755e80da2f",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/271250f/appsignal-x86_64-freebsd-all-static.tar.gz"
      },
    }
  end
end
