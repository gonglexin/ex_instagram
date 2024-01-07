defmodule ExInstagram.Repo.Migrations.CreateLogs do
  use Ecto.Migration

  def change do
    create table(:logs) do
      add :event, :string
      add :emoji, :string
      add :message, :text
      add :user_id, references(:users, on_delete: :nothing)
      add :post_id, references(:posts, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:logs, [:user_id])
    create index(:logs, [:post_id])
  end
end
