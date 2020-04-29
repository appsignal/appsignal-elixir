defmodule Appsignal.FallbacksTest do
  use ExUnit.Case

  test "crashes when using Appsignal.Phoenix" do
    try do
      Appsignal.Phoenix.__using__([])
    catch
      :error, %Appsignal.Phoenix.NotAvailableError{} -> :ok
    else
      _ -> flunk("Expected an Appsignal.Phoenix.NotAvailableError to be raised.")
    end
  end
end
