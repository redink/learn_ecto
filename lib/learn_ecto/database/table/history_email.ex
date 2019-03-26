defmodule LearnEcto.Database.Table.HistoryEmail do
  @moduledoc false
  use Ecto.Schema
  import Ecto.Changeset

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

  def insert(history_email) do
    Repo.insert(insert_changeset(history_email), on_conflict: :nothing)
  end

  # __end_of_module__
end
