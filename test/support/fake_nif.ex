defmodule Appsignal.FakeNif do
  @behaviour Appsignal.NifBehaviour
  use TestAgent, %{loaded?: true, running_in_container?: true, run_diagnose: false, diagnose: "%{}"}

  def loaded?, do: get(__MODULE__, :loaded?)
  def running_in_container?, do: get(__MODULE__, :running_in_container?)

  def diagnose do
    if get(__MODULE__, :run_diagnose) do
      Appsignal.Nif.diagnose
    else
      get(__MODULE__, :diagnose)
    end
  end
end
