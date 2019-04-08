defmodule LearnEcto.Database.Repo.Migrations.AddUserTable do
  use Ecto.Migration

  def change do
    create table("user", primary_key: false) do
      add(:id, :binary_id, primary_key: true, null: false, autogenerate: true)
      add(:email, :varchar, size: 64, null: false)
      add(:bio, :text)
      add(:name, :varchar, size: 64)
      add(:phone, :varchar, size: 64)
      add(:if_mfa, :boolean)
      timestamps()
    end

    create unique_index("user", :email)
    create unique_index("user", :phone)

    create table("history_email", primary_key: false) do
      add(:email, :varchar, size: 64, primary_key: true)
      add(:user_id, references("user", type: :binary_id), primary_key: true)
      timestamps()
    end

    create table("mfa", primary_key: false) do
      add(:mfa_secret, :varchar, size: 128)
      add(:recovery_codes, :text)
      add(:user_id, references("user", type: :binary_id), primary_key: true)
      timestamps()
    end
  end
end
