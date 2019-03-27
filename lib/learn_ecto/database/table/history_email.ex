defmodule LearnEcto.Database.Table.HistoryEmail do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias LearnEcto.Database.Repo

  @primary_key false
  schema("history_email") do
    belongs_to(:user, LearnEcto.Database.Table.User, type: :binary_id, primary_key: true)
    field(:email, :string, primary_key: true, null: false)
    timestamps(type: :utc_datetime_usec)
  end

  def insert_changeset(params, data \\ __MODULE__) do
    data
    |> struct()
    |> cast(params, [:user_id, :email])
    |> validate_required([:user_id, :email])
    |> foreign_key_constraint(:user_id, name: "history_email_user_id_fkey")
  end

  def get_all_by_email(email) do
    from(he in __MODULE__, where: he.email == ^email)
    |> select_merge([he], %{user_id: he.user_id})
    |> preload(:user)
    |> Repo.all()
  end

  def get_by_user_id_and_email(user_id, email) do
    Repo.get_by(from(__MODULE__, preload: [:user]), user_id: user_id, email: email)
  end

  # __end_of_module__
end
