defmodule LearnEcto.Database.Table.User do
  @moduledoc "The user database table."
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias LearnEcto.Database.Repo
  alias LearnEcto.Database.Table.HistoryEmail

  @primary_key {:id, :binary_id, [autogenerate: true]}
  schema("user") do
    field(:email, :string, null: false)
    field(:bio, :string, [])
    field(:name, :string, [])
    field(:phone, :string, [])
    has_many(:history_email, HistoryEmail, on_delete: :delete_all, on_replace: :delete)
    timestamps(type: :utc_datetime_usec)
  end

  def operation_changeset(params, data \\ __MODULE__) do
    data
    |> struct()
    |> cast(params, [:id, :email, :bio, :name, :phone])
    |> validate_required([:email])
    |> unique_constraint(:id, name: "user_pkey")
    |> unique_constraint(:email)
    |> unique_constraint(:phone, name: "user_phone_index")
    |> cast_assoc(:history_email)
  end

  def upsert(user) do
    upsert(Map.get(user, :id), user)
  end

  defp upsert(nil, %{email: email} = user) do
    user
    |> operation_changeset()
    |> put_assoc(:history_email, [%HistoryEmail{email: email}])
    |> Repo.insert()
  end

  defp upsert(user_id, %{email: email} = user) do
    original_data = Repo.get(from(__MODULE__, preload: :history_email), user_id) || %__MODULE__{}

    user
    |> operation_changeset(original_data)
    |> case do
      %{changes: changes} when changes == %{} ->
        original_data

      changeset ->
        original_history = build_assoc(email, Map.get(original_data, :history_email, []))

        changeset
        |> put_assoc(:history_email, original_history)
        |> Repo.insert(on_conflict: :replace_all, conflict_target: [:id])
    end
  end

  @doc false
  defp build_assoc(email, original_history) when is_list(original_history) do
    case Enum.any?(original_history, fn %{email: old_email} -> email == old_email end) do
      true -> original_history
      false -> [%HistoryEmail{email: email} | truncate(original_history)]
    end
  end

  defp build_assoc(email, _original_data) do
    build_assoc(email, [])
  end

  @doc false
  defp truncate(original_history) do
    case Enum.count(original_history) < 3 do
      true ->
        original_history

      false ->
        original_history
        |> Enum.sort(fn %{updated_at: updated_at_1}, %{updated_at: updated_at_2} ->
          updated_at_1 <= updated_at_2
        end)
        |> Enum.slice(-2..-1)
    end
  end

  # __end_of_module__
end
