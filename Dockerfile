FROM jkreeftmeijer/elixir-debug
ENV ERL_TOP=/usr/src/otp_src_25.3.2
ADD . /src
WORKDIR /src
RUN mix local.hex --force
RUN mix local.rebar --force
RUN mix deps.get

RUN curl -o priv/agent.tar.gz https://appsignal-agent-releases.global.ssl.fastly.net/$(elixir -r agent.exs --eval "IO.write(Appsignal.Agent.version)")/appsignal-x86_64-linux-all-static.tar.gz
RUN (cd priv && tar -xzf agent.tar.gz)

RUN gcc \
  -fsanitize=address \
  -g \
  -O3 \
  -pedantic \
  -Wall \
  -Wextra \
  -I/usr/local/lib/erlang/erts-13.2.2/include \
  -I./priv \
  -fPIC \
  -shared \
  -Wl,--whole-archive ./priv/libappsignal.a \
  -Wl,--no-whole-archive \
  -static-libgcc \
  -Wl,-fatal_warnings \
  -o ./priv/appsignal_extension.so \
  c_src/appsignal_extension.c

RUN mix deps.compile

CMD ASAN_OPTIONS=detect_leaks=1 $ERL_TOP/bin/cerl -asan -pa /usr/local/lib/elixir/lib/*/ebin -noshell -s elixir start_cli -extra --eval "Mix.start(); Mix.CLI.main()" -r spans.exs
