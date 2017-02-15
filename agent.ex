defmodule Appsignal.Agent do
  def version, do: "b15cca4"

  def triples do
    %{
      "x86_64-linux" => %{
        checksum: "1dc8a796e66f1730c104f012fa45fa5c348455450f2b1d6b886c7e615e9900b3",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/b15cca4/appsignal-x86_64-linux-all-static.tar.gz"
       },
      "i686-linux" => %{
        checksum: "2502b4557172297c7396b1dd7ea4ea7f996b1d5d003bdf8f84ad4d2a2de14dcf",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/b15cca4/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86-linux" => %{
        checksum: "2502b4557172297c7396b1dd7ea4ea7f996b1d5d003bdf8f84ad4d2a2de14dcf",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/b15cca4/appsignal-i686-linux-all-static.tar.gz"
       },
      "x86_64-darwin" => %{
        checksum: "c4ba4ba1fae6ac74f1ea71468d5123e350bba9467d299a63b5dba3d7e8d3d277",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/b15cca4/appsignal-x86_64-darwin-all-static.tar.gz"
       },
      "universal-darwin" => %{
        checksum: "c4ba4ba1fae6ac74f1ea71468d5123e350bba9467d299a63b5dba3d7e8d3d277",
        download_url: "https://appsignal-agent-releases.global.ssl.fastly.net/b15cca4/appsignal-x86_64-darwin-all-static.tar.gz"
       },
    }
  end
end
