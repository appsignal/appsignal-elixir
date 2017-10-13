defmodule Appsignal.Agent do
  def version, do: "91c966e"
  def triples do
    %{
      "x86_64-linux" => %{
        checksum: "795e2d11496ada3877f6d441450ddb662380a78a28442979e77300994efe86b6",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/91c966e/appsignal-x86_64-linux-all-static.tar.gz"
       },
      "i686-linux" => %{
        checksum: "7f4675199a2005b8869f2a2fdf649675136bd85f9fe422b74018f90af8260232",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/91c966e/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86-linux" => %{
        checksum: "7f4675199a2005b8869f2a2fdf649675136bd85f9fe422b74018f90af8260232",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/91c966e/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86_64-darwin" => %{
        checksum: "89f8cbbdc5291cf8bce826b0404c0af928a96bfadd8b4b636e234f1ceab85e10",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/91c966e/appsignal-x86_64-darwin-all-static.tar.gz"
       },
      "universal-darwin" => %{
        checksum: "89f8cbbdc5291cf8bce826b0404c0af928a96bfadd8b4b636e234f1ceab85e10",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/91c966e/appsignal-x86_64-darwin-all-static.tar.gz"
       },
    }
  end
end
