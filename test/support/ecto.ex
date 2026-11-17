if Appsignal.Dependencies.present?(:ecto_sql) do
  defmodule AppsignalTest.Ecto.Movie do
    @moduledoc false
    use Ecto.Schema
    import Ecto.Changeset

    schema "movies" do
      field(:title, :string)
      has_many(:characters, AppsignalTest.Ecto.Character)
      many_to_many(:actors, AppsignalTest.Ecto.Actor, join_through: "movies_actors")
    end

    def changeset(movie, params) do
      movie
      |> cast(params, [:title])
      |> validate_required([:title])
      |> unique_constraint(:title)
    end
  end

  defmodule AppsignalTest.Ecto.Character do
    @moduledoc false
    use Ecto.Schema

    schema "characters" do
      field(:name, :string)
      belongs_to(:movie, AppsignalTest.Ecto.Movie)
    end
  end

  defmodule AppsignalTest.Ecto.Actor do
    @moduledoc false
    use Ecto.Schema

    schema "actors" do
      field(:name, :string)
      many_to_many(:movies, AppsignalTest.Ecto.Movie, join_through: "movies_actors")
    end
  end

  defmodule AppsignalTest.Ecto.Migration do
    @moduledoc false
    use Ecto.Migration

    def change do
      create table(:movies) do
        add(:title, :string, null: false)
      end

      create(unique_index(:movies, [:title]))

      create table(:characters) do
        add(:name, :string)
        add(:movie_id, references(:movies))
      end

      create table(:actors) do
        add(:name, :string)
      end

      create table(:movies_actors, primary_key: false) do
        add(:movie_id, references(:movies))
        add(:actor_id, references(:actors))
      end
    end
  end

  defmodule Appsignal.Test.Repo do
    @moduledoc false
    use Ecto.Repo, otp_app: :appsignal, adapter: Ecto.Adapters.SQLite3
  end

  defmodule AppsignalTest.Ecto.AppsignalRepo do
    @moduledoc false
    use Appsignal.Ecto.Repo, otp_app: :appsignal, adapter: Ecto.Adapters.SQLite3
  end

  defmodule AppsignalTest.Ecto.Database do
    @moduledoc """
    Starts a repo under the test supervisor on a new in-memory SQLite
    database, and migrates it.

    Every connection to `:memory:` opens a database of its own, so the repo
    has a pool of one connection.
    """

    def start(repo, migrations \\ [AppsignalTest.Ecto.Migration]) do
      ExUnit.Callbacks.start_supervised!({repo, database: ":memory:", pool_size: 1})

      migrations = migrations |> Enum.with_index(1) |> Enum.map(fn {m, i} -> {i, m} end)
      Ecto.Migrator.run(repo, migrations, :up, all: true, log: false)
      repo
    end

    @doc """
    Attaches `Appsignal.Ecto` to a repo that is not in the configuration
    until the test exits.
    """
    def attach(repo) do
      :ok = Appsignal.Ecto.attach(:appsignal, repo)
      ExUnit.Callbacks.on_exit(fn -> :telemetry.detach({Appsignal.Ecto, event(repo)}) end)
      repo
    end

    def event(repo) do
      repo
      |> Module.split()
      |> Enum.map(&(&1 |> Macro.underscore() |> String.to_atom()))
      |> Kernel.++([:query])
    end
  end
end
