defmodule Appsignal.ErrorLoggerHandler do
  alias Appsignal.ErrorHandler

  def init(state) do
    ErrorHandler.init(state)
  end

  def handle_event(event, state) do
    ErrorHandler.handle_event(event, state)
  end

  def handle_info(event, state) do
    ErrorHandler.handle_info(event, state)
  end
end
