defmodule Appsignal.Error.BackendTest do
  use ExUnit.Case, async: true

  test "is added as a Logger backend" do
    assert {:error, :already_present} = Logger.add_backend(Appsignal.Error.Backend)
  end
end
