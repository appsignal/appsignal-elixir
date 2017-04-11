defmodule AppsignalTest.Utils do
  def clear_env do
    Application.delete_env(:appsignal, :config)

    System.get_env
    |> Enum.filter(
      fn({"APPSIGNAL_" <> _, _}) -> true;
      ({"_APPSIGNAL_" <> _, _}) -> true;
      ({"APP_REVISION", _}) -> true;
      ({"DYNO", _}) -> true;
      (_) -> false end
    ) |> Enum.each(fn({key, _}) ->
      System.delete_env(key)
    end)
  end
end
