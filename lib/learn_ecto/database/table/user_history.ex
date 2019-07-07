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
    field(:position, :integer)
    timestamps(type: :utc_datetime_usec)
  end

  def operation_changeset(params, data \\ __MODULE__) do
    data
    |> struct()
    |> cast(params, [:id, :user_id, :device_id, :position])
    |> validate_required([:position])
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

  def all do
    Repo.all(from(__MODULE__))
  end

  @doc false
  @logic_key_list [:user_id, :device_id]
  def read_by_logic_key(data) do
    Repo.get_by(
      __MODULE__,
      data
      |> Enum.filter(fn {k, v} -> k in @logic_key_list and not is_nil(v) end)
      |> IO.inspect()
    )
  end

  # __end_of_module__
end
