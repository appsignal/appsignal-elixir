defmodule Appsignal.TestProbe do
  def call do
    Appsignal.increment_counter("test_probe_called", 1)
  end
end
