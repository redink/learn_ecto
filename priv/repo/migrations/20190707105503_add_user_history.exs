defmodule LearnEcto.Database.Repo.Migrations.AddUserHistory do
  use Ecto.Migration

  def change do
    create table("user_history", primary_key: false) do
      add(:id, :binary_id, primary_key: true, null: false, autogenerate: true)
      add(:user_id, :varchar, size: 64)
      add(:device_id, :varchar, size: 64)
      add(:content_id, :varchar, size: 64)
      add(:content_type, :varchar, size: 64)
      add(:position, :integer)
      timestamps()
    end

    create unique_index("user_history", [:user_id, :content_id, :content_type])
    create unique_index("user_history", [:device_id, :content_id, :content_type])
    create index("user_history", :user_id)
    create index("user_history", :device_id)
  end
end
