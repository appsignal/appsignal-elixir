defmodule Appsignal.CheckIn.Scheduler.Debounce do
  @initial_debounce_milliseconds 100
  @between_transmissions_debounce_milliseconds 10_000

  @system Application.compile_env(
            :appsignal,
            :system,
            System
          )

  def milliseconds_until_next_transmission(nil), do: @initial_debounce_milliseconds

  def milliseconds_until_next_transmission(last_transmission_milliseconds) do
    max(
      @initial_debounce_milliseconds,
      @between_transmissions_debounce_milliseconds -
        milliseconds_since(last_transmission_milliseconds)
    )
  end

  defp milliseconds_since(timestamp) do
    @system.system_time(:millisecond) - timestamp
  end
end

defmodule Appsignal.CheckIn.Scheduler do
  use GenServer

  alias Appsignal.CheckIn.Event

  @debounce Application.compile_env(
              :appsignal,
              :appsignal_checkin_debounce,
              Appsignal.CheckIn.Scheduler.Debounce
            )

  @transmitter Application.compile_env(
                 :appsignal,
                 :appsignal_transmitter,
                 Appsignal.Transmitter
               )

  @integration_logger Application.compile_env(
                        :appsignal,
                        :appsignal_integration_logger,
                        Appsignal.IntegrationLogger
                      )

  @system Application.compile_env(
            :appsignal,
            :system,
            System
          )

  @impl true
  def init(_init_arg) do
    # Ensure that the GenServer traps exits so that we can attempt to
    # transmit any remaining events before terminating.
    Process.flag(:trap_exit, true)
    {:ok, initial_state()}
  end

  def start_link(_init_arg) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def schedule(event) do
    if Appsignal.Config.active?() do
      GenServer.cast(__MODULE__, {:schedule, event})
    else
      @integration_logger.debug("AppSignal not active, not scheduling #{Event.describe([event])}")
    end

    :ok
  end

  @impl true
  def handle_cast({:schedule, event}, state) do
    @integration_logger.trace("Scheduling #{Event.describe([event])} to be transmitted")

    schedule_transmission(state)

    {:noreply, %{state | events: add_event(state.events, event)}}
  end

  @impl true
  def handle_info(:transmit, %{events: events}) do
    # Remove the stored events from the state before transmitting them,
    # to avoid transmitting them twice if the process receives a shutdown
    # signal during the transmission.
    {:noreply, initial_state(), {:continue, {:transmit, events}}}
  end

  @impl true
  def handle_continue({:transmit, events}, state) do
    description = Event.describe(events)

    config = Appsignal.Config.config()
    endpoint = "#{config[:logging_endpoint]}/check_ins/json"

    case @transmitter.transmit_and_close(endpoint, {Enum.reverse(events), :ndjson}, config) do
      {:ok, %{status: status_code}, _} when status_code in 200..299 ->
        @integration_logger.trace("Transmitted #{description}")

      {:ok, %{status: status_code}, _} ->
        @integration_logger.error(
          "Failed to transmit #{description}: status code was #{status_code}"
        )

      {:error, reason} ->
        @integration_logger.error("Failed to transmit #{description}: #{reason}")
    end

    {
      :noreply,
      %{state | last_transmission_milliseconds: @system.system_time(:millisecond)},
      :hibernate
    }
  end

  @impl true
  def terminate(_reason, %{events: events}) when length(events) > 0 do
    # If any events are stored, attempt to transmit them before the
    # process is terminated.
    handle_continue({:transmit, events}, initial_state())
  end

  def terminate(_reason, _state), do: nil

  defp initial_state do
    %{events: [], last_transmission_milliseconds: nil}
  end

  defp schedule_transmission(%{events: []} = state) do
    Process.send_after(
      self(),
      :transmit,
      @debounce.milliseconds_until_next_transmission(state.last_transmission_milliseconds)
    )
  end

  defp schedule_transmission(_state) do
    # The transmission should only be scheduled when the first event is
    # being added, so we don't need to schedule it again.
    nil
  end

  defp add_event(events, event) do
    # Remove redundant events, keeping the newly added one, which
    # should be the one with the most recent timestamp.
    [
      event
      | Enum.reject(events, fn existing_event ->
          is_redundant = Event.redundant?(existing_event, event)

          if is_redundant do
            @integration_logger.debug("Replacing previously scheduled #{Event.describe([event])}")
          end

          is_redundant
        end)
    ]
  end
end
