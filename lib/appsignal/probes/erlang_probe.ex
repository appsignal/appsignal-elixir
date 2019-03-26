defmodule Appsignal.Probes.ErlangProbe do
  @appsignal Application.get_env(:appsignal, :appsignal, Appsignal)

  def call do
    io_metrics()
    scheduler_metrics()
    process_metrics()
    memory_metrics()
  end

  defp io_metrics do
    {{:input, input}, {:output, output}} = :erlang.statistics(:io)
    set_gauge("erlang_io", Kernel.div(input, 1024), %{type: "input"})
    set_gauge("erlang_io", Kernel.div(output, 1024), %{type: "output"})
  end

  defp scheduler_metrics do
    set_gauge("erlang_schedulers", :erlang.system_info(:schedulers), %{type: "total"})

    set_gauge(
      "erlang_schedulers",
      :erlang.system_info(:schedulers_online),
      %{type: "online"}
    )
  end

  defp process_metrics do
    set_gauge("erlang_processes", :erlang.system_info(:process_limit), %{type: "limit"})

    set_gauge("erlang_processes", :erlang.system_info(:process_count), %{type: "count"})
  end

  defp memory_metrics do
    memory = :erlang.memory()

    Enum.each(memory, fn {key, value} ->
      set_gauge("erlang_memory", Kernel.div(value, 1024), %{type: to_string(key)})
    end)
  end

  defp set_gauge(name, value, tags) do
    @appsignal.set_gauge(
      name,
      value,
      Map.merge(tags, %{host_metric: "", hostname: hostname()})
    )
  end

  defp hostname do
    {:ok, hostname} = :inet.gethostname()
    config = Application.get_env(:appsignal, :config)
    config[:hostname] || hostname
  end
end
