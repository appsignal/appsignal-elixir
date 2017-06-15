defmodule Appsignal.Agent do
  def version, do: "d5b0750"

  def triples do
    %{
      "x86_64-linux" => %{
        checksum: "1ff68355e089d855927dfd5058e635bf1ad3196f8f9c6f4577ac6854bca133bf",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d5b0750/appsignal-x86_64-linux-all-static.tar.gz"
       },
      "i686-linux" => %{
        checksum: "fcfa0d7a0ebd628d24ba799e0c765210ee2c93d1eff6930b94fd9ca4383cb278",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d5b0750/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86-linux" => %{
        checksum: "fcfa0d7a0ebd628d24ba799e0c765210ee2c93d1eff6930b94fd9ca4383cb278",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d5b0750/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86_64-darwin" => %{
        checksum: "9e394fa5f473f81ef4f322b3802aeee2b08854ea43a75f9c22c6185b4ffd960a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d5b0750/appsignal-x86_64-darwin-all-static.tar.gz"
       },
      "universal-darwin" => %{
        checksum: "9e394fa5f473f81ef4f322b3802aeee2b08854ea43a75f9c22c6185b4ffd960a",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/d5b0750/appsignal-x86_64-darwin-all-static.tar.gz"
       },
    }
  end
end
