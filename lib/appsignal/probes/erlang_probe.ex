defmodule Appsignal.Probes.ErlangProbe do
  @moduledoc false

  def call(sample \\ nil) do
    next_sample = sample_schedulers()

    sample
    |> metrics(next_sample)
    |> Enum.each(fn {key, value, tags} ->
      Appsignal.set_gauge(key, value, tags)
    end)

    next_sample
  end

  def metrics(sample, next_sample) do
    metrics =
      io_metrics() ++
        scheduler_metrics() ++
        process_metrics() ++
        memory_metrics() ++
        atom_metrics() ++
        run_queue_lengths() ++
        scheduler_utilization_metrics(sample, next_sample)

    Enum.map(metrics, fn {key, value, tags} ->
      {key, value, Map.merge(tags, %{hostname: Appsignal.Utils.Hostname.hostname()})}
    end)
  end

  defp io_metrics do
    {{:input, input}, {:output, output}} = :erlang.statistics(:io)

    [
      {"erlang_io", Kernel.div(input, 1024), %{type: "input"}},
      {"erlang_io", Kernel.div(output, 1024), %{type: "output"}}
    ]
  end

  defp scheduler_metrics do
    [
      {"erlang_schedulers", :erlang.system_info(:schedulers), %{type: "total"}},
      {"erlang_schedulers", :erlang.system_info(:schedulers_online), %{type: "online"}}
    ]
  end

  defp process_metrics do
    [
      {"erlang_processes", :erlang.system_info(:process_limit), %{type: "limit"}},
      {"erlang_processes", :erlang.system_info(:process_count), %{type: "count"}}
    ]
  end

  defp memory_metrics do
    memory = :erlang.memory()

    Enum.map(memory, fn {key, value} ->
      {"erlang_memory", Kernel.div(value, 1024), %{type: to_string(key)}}
    end)
  end

  defp atom_metrics do
    [
      {"erlang_atoms", :erlang.system_info(:atom_limit), %{type: "limit"}},
      {"erlang_atoms", :erlang.system_info(:atom_count), %{type: "count"}}
    ]
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

    [
      {"total_run_queue_lengths", total, %{type: "total"}},
      {"total_run_queue_lengths", cpu, %{type: "cpu"}},
      {"total_run_queue_lengths", total - cpu, %{type: "io"}}
    ]
  end

  defp scheduler_utilization_metrics(nil, _), do: []

  defp scheduler_utilization_metrics(sample, next_sample) do
    utilization = scheduler_utilization(sample, next_sample)

    utilization
    |> Enum.map(&Tuple.to_list/1)
    |> Enum.filter(fn [type | _] -> type == :normal end)
    |> Enum.map(fn [_, id, value, _] ->
      {"erlang_scheduler_utilization", value * 100, %{type: "normal", id: "#{id}"}}
    end)
  end

  if Code.ensure_loaded?(:scheduler) do
    def sample_schedulers, do: :scheduler.sample()

    defp scheduler_utilization(sample, next_sample) do
      :scheduler.utilization(sample, next_sample)
    end
  else
    def sample_schedulers do
      scheduler_wall_time = Enum.sort(:erlang.statistics(:scheduler_wall_time))
      scheduler_count = :erlang.system_info(:schedulers)

      Enum.take(scheduler_wall_time, scheduler_count)
    end

    defp scheduler_utilization(sample, next_sample) do
      Enum.map(Enum.zip(sample, next_sample), fn {old, new} ->
        {id, old_active, old_total} = old
        {^id, new_active, new_total} = new

        utilization = (new_active - old_active) / (new_total - old_total)
        {:normal, id, utilization, nil}
      end)
    end
  end
end
