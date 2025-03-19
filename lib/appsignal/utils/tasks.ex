defmodule :appsignal_tasks do
  @moduledoc false
  def diagnose(args \\ []) do
    Mix.Tasks.Appsignal.Diagnose.run(args)
    :init.stop()
  end

  def demo do
    Mix.Tasks.Appsignal.Demo.run(nil)
    :init.stop()
  end

  def check_install do
    Mix.Tasks.Appsignal.CheckInstall.run(nil)
    :init.stop()
  end
end
