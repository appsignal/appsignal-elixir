defmodule Appsignal.Agent do
  def version, do: "5464697"

  def triples do
    %{
      "x86_64-linux" => %{
        checksum: "a70f22af18f50ea1a02adf4ef88f68047b353a185fd100e8a61bc7ade87095bc",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/5464697/appsignal-x86_64-linux-all-static.tar.gz"
       },
      "i686-linux" => %{
        checksum: "2101667a3c56dfe78436c4f25b763a1db2028dd6ebe247b64d3c616066269879",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/5464697/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86-linux" => %{
        checksum: "2101667a3c56dfe78436c4f25b763a1db2028dd6ebe247b64d3c616066269879",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/5464697/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86_64-darwin" => %{
        checksum: "496f3348ae0e957b2610bb82ae23ab3c9878483a01e447a9f27537c99bd9f69d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/5464697/appsignal-x86_64-darwin-all-static.tar.gz"
       },
      "universal-darwin" => %{
        checksum: "496f3348ae0e957b2610bb82ae23ab3c9878483a01e447a9f27537c99bd9f69d",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/5464697/appsignal-x86_64-darwin-all-static.tar.gz"
       },
    }
  end
end
