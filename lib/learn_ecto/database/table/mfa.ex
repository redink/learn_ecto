defmodule LearnEcto.Database.Table.Mfa do
  @moduledoc "The mfa database table."

  use Ecto.Schema
  import Ecto.Changeset

  alias LearnEcto.Database.Repo

  @primary_key false
  schema "mfa" do
    belongs_to(:user, LearnEcto.Database.Table.User, type: :binary_id, primary_key: true)
    field(:mfa_secret, :string)
    field(:recovery_codes, :string)
    timestamps(type: :utc_datetime_usec)
  end

  def operation_changeset(params, data \\ __MODULE__) do
    data
    |> struct()
    |> cast(params, [:user_id, :mfa_secret, :recovery_codes])
    |> validate_required([:user_id, :mfa_secret, :recovery_codes])
    |> foreign_key_constraint(:user_id, name: "mfa_user_id_fkey")
  end

  def insert(changeset, options \\ []) do
    Repo.insert(changeset, options)
  end

  def preload_user(mfa), do: Repo.preload(mfa, [:user])

  def get_by_user_id(user_id) do
    Repo.get(__MODULE__, user_id)
  end

  # __end_of_module__
end
