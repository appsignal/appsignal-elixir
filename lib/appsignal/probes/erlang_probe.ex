defmodule Appsignal.Probes.ErlangProbe do
  @appsignal Application.get_env(:appsignal, :appsignal, Appsignal)
  @inet Application.get_env(:appsignal, :inet, :inet)

  def call do
    io_metrics()
    scheduler_metrics()
    process_metrics()
    memory_metrics()
    run_queue_lengths()
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

  defp run_queue_lengths do
    {otp_release, _} = Integer.parse(System.otp_release())

    total =
      if otp_release < 20 do
        Enum.sum(:erlang.statistics(:run_queue_lengths))
      else
        :erlang.statistics(:total_run_queue_lengths_all)
      end

    cpu =
      if otp_release < 20 do
        # Before OTP 20.0 there were only normal run queues.
        total
      else
        :erlang.statistics(:total_run_queue_lengths)
      end

    set_gauge("total_run_queue_lengths", total, %{type: "total"})
    set_gauge("total_run_queue_lengths", cpu, %{type: "cpu"})
    set_gauge("total_run_queue_lengths", total - cpu, %{type: "io"})
  end

  defp set_gauge(name, value, tags) do
    @appsignal.set_gauge(
      name,
      value,
      Map.merge(tags, %{hostname: hostname()})
    )
  end

  defp hostname do
    case Application.fetch_env(:appsignal, :config) do
      {:ok, %{hostname: hostname}} ->
        hostname

      _ ->
        {:ok, hostname} = @inet.gethostname()
        List.to_string(hostname)
    end
  end
end
