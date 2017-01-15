defmodule Appsignal.ErrorHandler.ErrorExtracterTest do

  use ExUnit.Case

  alias Appsignal.ErrorHandler

  @argument_error %ArgumentError{message: "cannot convert nil to param"}
  test "bare ArgumentError" do
    {r, m} = ErrorHandler.extract_reason_and_message(@argument_error, "Template error")
    assert "ArgumentError" == r
    assert "Template error: cannot convert nil to param" == m
  end

  test "string error" do
    {r, m} = ErrorHandler.extract_reason_and_message("file not found", "Foo error")
    assert "file not found" == r
    assert "Foo error" == m
  end

  test "atom error" do
    {r, m} = ErrorHandler.extract_reason_and_message(RuntimeError, "Foo error")
    assert "runtime error" == r
    assert "Foo error" == m
  end

  test "unknown module atom error" do
    {r, m} = ErrorHandler.extract_reason_and_message(SomeSpecialRuntimeError, "Foo error")
    assert "SomeSpecialRuntimeError" == r
    assert "Foo error" == m
  end

  test "arbitrary term error" do
    {r, m} = ErrorHandler.extract_reason_and_message({:error, :badarg}, "Badarg error")
    assert "{:error, :badarg}" == r
    assert "Badarg error" == m
  end

  @undefined_error_extract %Protocol.UndefinedError{description: "", protocol: Enumerable, value: {:error, {%Poison.SyntaxError{message: "Unexpected token: <\", token: \"<"}, [{Poison.Parser, :parse!, 2, [file: 'lib/poison/parser.ex', line: 56]}, {Poison, :decode!, 2, [file: 'lib/poison.ex', line: 83]}, {HTTPoison.Base, :response, 6, [file: 'lib/httpoison/base.ex', line: 413]}, {WebApp.Backend, :request!, 5, [file: 'web/support/backend.ex', line: 3]}, {WebApp.Backend, :get, 2, [file: 'web/support/backend.ex', line: 161]}, {WebApp.Backend, :search_deals_uncached, 1, [file: 'web/support/backend.ex', line: 105]}, {:depcache, :memo, 5, [file: '/home/user/ap/deps/depcache/src/depcache.erl', line: 100]}, {WebApp.AppChannel, :handle_in, 3, [file: 'web/channels/app_channel.ex', line: 41]}]}}}

  test "Protocol.UndefinedError extract" do
    {r, m} = ErrorHandler.extract_reason_and_message(@undefined_error_extract, "JSON error")
    assert "Poison.SyntaxError" == r
    assert "JSON error: Unexpected token: <\", token: \"<" == m
  end

  @undefined_error %Protocol.UndefinedError{description: "", protocol: Enumerable, value: {:error, {%Protocol.UndefinedError{description: "", protocol: Enumerable, value: {:error, :foo}}, [{Enumerable, :impl_for!, 1, [file: 'lib/enum.ex', line: 1]}, {Enumerable, :reduce, 3, [file: 'lib/enum.ex', line: 116]}, {Enum, :reduce, 3, [file: 'lib/enum.ex', line: 1636]}, {Enum, :sort, 2, [file: 'lib/enum.ex', line: 1969]}, {:depcache, :memo, 5, [file: '/home/user/ap/deps/depcache/src/depcache.erl', line: 100]}, {WebApp.AppChannel, :collect_places_map, 1, [file: 'web/channels/app_channel.ex', line: 148]}, {WebApp.AppChannel, :handle_in, 3, [file: 'web/channels/app_channel.ex', line: 58]}, {Phoenix.Channel.Server, :"-handle_info/2-fun-4-", 4, [file: 'lib/phoenix/channel/server.ex', line: 226]}, {:gen_server, :try_dispatch, 4, [file: 'gen_server.erl', line: 615]}, {:gen_server, :handle_msg, 5, [file: 'gen_server.erl', line: 681]}, {:proc_lib, :init_p_do_apply, 3, [file: 'proc_lib.erl', line: 240]}]}}}

  test "Protocol.UndefinedError" do
    {r, m} = ErrorHandler.extract_reason_and_message(@undefined_error, "Foo error")
    assert "Protocol.UndefinedError" == r
    assert "Foo error: protocol Enumerable not implemented for {:error, :foo}" == m
  end

end
