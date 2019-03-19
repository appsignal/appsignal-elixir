defmodule Appsignal.Probes.ErlangProbe do
  def call do
    io_metrics()
    scheduler_metrics()
    process_metrics()
    memory_metrics()
  end

  defp io_metrics do
    {{:input, input}, {:output, output}} = :erlang.statistics(:io)
    Appsignal.set_gauge("erlang_io", Kernel.div(input, 1024), %{type: "input"})
    Appsignal.set_gauge("erlang_io", Kernel.div(output, 1024), %{kind: "output"})
  end

  defp scheduler_metrics do
    Appsignal.set_gauge("erlang_schedulers", :erlang.system_info(:schedulers), %{kind: "total"})

    Appsignal.set_gauge(
      "erlang_schedulers",
      :erlang.system_info(:schedulers_online),
      %{kind: "online"}
    )
  end

  defp process_metrics do
    Appsignal.set_gauge("erlang_processes", :erlang.system_info(:process_limit), %{kind: "limit"})
    Appsignal.set_gauge("erlang_processes", :erlang.system_info(:process_count), %{kind: "count"})
  end

  defp memory_metrics do
    memory = :erlang.memory()

    Enum.each(memory, fn {key, value} ->
      Appsignal.set_gauge("erlang_memory", Kernel.div(value, 1024), %{kind: key})
    end)
  end
end
