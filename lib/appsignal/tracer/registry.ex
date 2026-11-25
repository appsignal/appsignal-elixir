defmodule Appsignal.Tracer.Registry do
  @moduledoc false

  alias Appsignal.Span

  @table :"$appsignal_registry"

  def new do
    :ets.new(@table, [:named_table, :public, :duplicate_bag])
  end

  def insert(%Span{pid: pid} = span) do
    :ets.insert(@table, {pid, span})
  rescue
    ArgumentError -> nil
  end

  def remove(%Span{pid: pid} = span) do
    :ets.delete_object(@table, {pid, span})
  rescue
    ArgumentError -> false
  end

  def lookup(pid) do
    :ets.lookup(@table, pid)
  rescue
    ArgumentError -> []
  end

  def current(pid) do
    case pid |> lookup() |> List.last() do
      {_pid, %Span{} = span} -> span
      _ -> nil
    end
  end

  def root(pid) do
    case lookup(pid) do
      [{_pid, %Span{} = root} | _] -> root
      _ -> nil
    end
  end

  def ignore(pid) do
    delete(pid)

    try do
      :ets.insert(@table, {pid, :ignore})
    rescue
      ArgumentError -> nil
    end
  end

  def ignored?(pid) do
    lookup(pid) == [{pid, :ignore}]
  end

  def delete(pid) do
    :ets.delete(@table, pid)
    :ok
  rescue
    ArgumentError -> :ok
  end
end
