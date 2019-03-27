defmodule LearnEcto.Context.User do
  @moduledoc false

  import Ecto.Query

  alias LearnEcto.Database.Table.User, as: ModelUser
  alias LearnEcto.Database.Table.HistoryEmail, as: ModelHistoryEmail

  def get(user_id) do
    # get user first
    ModelUser.get_by_id(user_id)
  end

  def upsert(user) do
    upsert(Map.get(user, :id), user)
  end

  @doc false
  defp upsert(nil, %{email: email} = user) do
    user
    |> ModelUser.operation_changeset()
    |> Ecto.Changeset.put_assoc(:history_email, [%ModelHistoryEmail{email: email}])
    |> ModelUser.insert()
    |> update_cache()
  end

  defp upsert(user_id, user) do
    original_data =
      ModelUser.get(from(ModelUser, preload: :history_email), user_id) || %ModelUser{}

    case ModelUser.operation_changeset(user, original_data) do
      %{changes: changes} when changes == %{} ->
        original_data

      changeset ->
        changeset
        |> build_new_changest(user, original_data)
        |> delete_cache(user_id)
        |> ModelUser.insert(on_conflict: :replace_all, conflict_target: [:id])
        |> update_cache()
    end
  end

  @doc false
  defp update_cache({:ok, data}) do
    {:ok, data}
  end

  defp update_cache(error), do: error

  @doc false
  defp delete_cache(changeset, user_id) do
    _ = user_id
    changeset
  end

  @doc false
  defp build_new_changest(changeset, user, original_data) do
    changeset
    |> Map.get(:changes)
    |> Enum.reduce(
      changeset,
      fn
        {:email, _}, changeset ->
          changeset
          |> build_assoc_with_history_email(user.email, Map.get(original_data, :history_email))

        _, changeset ->
          changeset
      end
    )
  end

  @doc false
  defp build_assoc_with_history_email(changeset, email, original_history)
       when is_list(original_history) do
    new_history_email =
      if Enum.any?(original_history, fn %{email: old_email} -> email == old_email end) do
        original_history
      else
        [%ModelHistoryEmail{email: email} | truncate(original_history)]
      end

    Ecto.Changeset.put_assoc(changeset, :history_email, new_history_email)
  end

  defp build_assoc_with_history_email(changeset, _email, _) do
    changeset
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
