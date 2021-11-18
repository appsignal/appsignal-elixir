defmodule Appsignal.Probes.ErlangProbe do
  @moduledoc false

  require Appsignal.Utils

  @appsignal Appsignal.Utils.compile_env(:appsignal, :appsignal, Appsignal)
  @inet Appsignal.Utils.compile_env(:appsignal, :inet, :inet)

  def call(sample \\ nil) do
    next_sample = :scheduler.sample()

    io_metrics()
    scheduler_metrics()
    process_metrics()
    memory_metrics()
    atom_metrics()
    run_queue_lengths()
    scheduler_utilization_metrics(sample, next_sample)

    next_sample
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

  defp atom_metrics do
    set_gauge("erlang_atoms", :erlang.system_info(:atom_limit), %{type: "limit"})
    set_gauge("erlang_atoms", :erlang.system_info(:atom_count), %{type: "count"})
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

  defp scheduler_utilization_metrics(nil, _), do: nil

  defp scheduler_utilization_metrics(sample, next_sample) do
    utilization = :scheduler.utilization(sample, next_sample)

    utilization
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.filter(fn [type | _] -> type == :normal end)
    |> Enum.each(fn [_, id, value, _] ->
      set_gauge("erlang_scheduler_utilization", value * 100, %{type: "normal", id: "#{id}"})
    end)
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
