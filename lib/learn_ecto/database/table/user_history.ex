defmodule LearnEcto.Database.Table.UserHistory do
  @moduledoc false

  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query

  alias LearnEcto.Database.Repo

  @primary_key {:id, :binary_id, [autogenerate: true]}
  schema("user_history") do
    field(:user_id, :string)
    field(:device_id, :string)
    field(:content_id, :string)
    field(:content_type, :string)
    field(:position, :integer)
    timestamps(type: :utc_datetime_usec)
  end

  def operation_changeset(params, data \\ __MODULE__) do
    data
    |> struct()
    |> cast(params, [:id, :user_id, :device_id, :content_id, :content_type, :position])
    |> validate_required([:position, :content_id, :content_type])
  end

  def upsert(data) do
    case read_by_logic_key(data) do
      nil ->
        data
        |> operation_changeset()
        |> Repo.insert()

      original_data ->
        data
        |> operation_changeset(original_data)
        |> Repo.update()
    end
  end

  def upsert_v2(data) do
    data
    |> operation_changeset()
    |> Repo.insert(on_conflict: :replace_all, conflict_target: determine_conflict_target(data))
  end

  def all do
    Repo.all(from(__MODULE__))
  end

  @doc false
  @logic_key_list [:user_id, :device_id, :content_id, :content_type]
  def read_by_logic_key(data) do
    Repo.get_by(
      __MODULE__,
      data
      |> Enum.filter(fn
        {k, v} -> k in @logic_key_list and not is_nil(v)
      end)
    )
  end

  @doc false
  defp determine_conflict_target(data) do
    case Map.get(data, :user_id) do
      nil -> [:device_id, :content_id, :content_type]
      _ -> [:user_id, :content_id, :content_type]
    end
  end

  # __end_of_module__
end
