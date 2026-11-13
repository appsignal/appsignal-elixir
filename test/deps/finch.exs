# Finch comes with AppSignal, so this set only adds the server the Finch
# tests send their requests to.
{server, _binding} = Code.eval_file("test/deps/shared/http_server.exs")
server
