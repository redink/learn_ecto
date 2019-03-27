defmodule LearnEcto.Database.Table.User do
  @moduledoc "The user database table."
  use Ecto.Schema
  import Ecto.Changeset
  # import Ecto.Query

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

  #
  def get_by_id(id) do
    Repo.get(__MODULE__, id)
  end

  def get(%Ecto.Query{} = query, key) do
    Repo.get(query, key)
  end

  def insert(changeset, options \\ []) do
    Repo.insert(changeset, options)
  end

  # __end_of_module__
end
