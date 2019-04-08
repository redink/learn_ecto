defmodule LearnEcto.Context.Mfa do
  @moduledoc false

  alias Ecto.Multi
  alias LearnEcto.Database.Repo
  alias LearnEcto.Database.Table.{Mfa, User}

  @doc """

  """
  def enable_mfa(%{user_id: _, mfa_secret: _, recovery_codes: _} = mfa) do
    Multi.new()
    |> Multi.insert(:mfa, Mfa.operation_changeset(mfa),
      on_conflict: :replace_all,
      conflict_target: [:user_id]
    )
    |> update_user_if_mfa(true)
    |> Repo.transaction()
  end

  @doc """

  """
  def disable_mfa(user_id) do
    case Mfa.get_by_user_id(user_id) do
      nil ->
        :ok

      mfa ->
        Multi.new()
        |> Multi.delete(:mfa, mfa)
        |> update_user_if_mfa(false)
        |> Repo.transaction()
    end
  end

  @doc false
  defp update_user_if_mfa(multi, flag) do
    update_fn = fn _repo, %{mfa: mfa} ->
      %{user: %{id: user_id} = user} = Mfa.preload_user(mfa)
      User.update(user, %{id: user_id, if_mfa: flag})
    end

    Multi.run(multi, :update_user_if_mfa, update_fn)
  end

  # __end_of_module__
end
