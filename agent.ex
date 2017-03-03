defmodule Appsignal.Agent do
  def version, do: "413c222"

  def triples do
    %{
      "x86_64-linux" => %{
        checksum: "0154d797bf3873b40e2499140284e05c91070a13f25ec54a0df6d60c2e0f7c36",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/413c222/appsignal-x86_64-linux-all-static.tar.gz"
       },
      "i686-linux" => %{
        checksum: "f7773d34618b742edeac39bf41ee6588ac0d5c8d182a459a86dc12c26020f188",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/413c222/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86-linux" => %{
        checksum: "f7773d34618b742edeac39bf41ee6588ac0d5c8d182a459a86dc12c26020f188",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/413c222/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86_64-darwin" => %{
        checksum: "dafa8467812ceaeecb96c8ca2768f4b667fc404935c7ef53e6d7c758dc6259c0",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/413c222/appsignal-x86_64-darwin-all-static.tar.gz"
       },
      "universal-darwin" => %{
        checksum: "dafa8467812ceaeecb96c8ca2768f4b667fc404935c7ef53e6d7c758dc6259c0",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/413c222/appsignal-x86_64-darwin-all-static.tar.gz"
       },
    }
  end
end
