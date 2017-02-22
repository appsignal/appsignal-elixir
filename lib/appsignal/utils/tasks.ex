defmodule :appsignal_tasks do
  def diagnose do
    Mix.Tasks.Appsignal.Diagnose.run(nil)
    :init.stop
  end

  def demo do
    Mix.Tasks.Appsignal.Demo.run(nil)
    :init.stop
  end
end
