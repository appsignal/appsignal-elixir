defmodule AppsignalTest.CompileProbe do
  @moduledoc false

  # Compiled into the package only when test/app builds it as a dependency.
  # Mix does not recompile a module when the code path changes, so the
  # answer below is recomputed on every compile.
  def __mix_recompile__?, do: true

  @libraries for path <- Path.wildcard("test/deps/*.exs"),
                 Path.basename(path) != "all.exs",
                 dependency <- elem(Code.eval_file(path), 0),
                 uniq: true,
                 do: elem(dependency, 0)

  @visible Enum.reject(@libraries, &(:code.where_is_file(~c"#{&1}.app") == :non_existing))

  # The libraries from the dependency sets whose application was on the code
  # path while the package compiled.
  def visible, do: @visible
end
