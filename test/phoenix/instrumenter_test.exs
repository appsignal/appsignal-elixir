defmodule Appsignal.Phoenix.InstrumenterTest do
  use ExUnit.Case, async: true

  defmodule MyInstrumenter do

    import Appsignal.Phoenix.InstrumenterDSL
    instrumenter :phoenix_controller_call
    instrumenter :phoenix_controller_render
    instrumenter :foo

  end

end
