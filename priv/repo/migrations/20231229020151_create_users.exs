defmodule ExInstagram.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :language, :string, default: "English"
      add :vibe, :string

      timestamps(type: :utc_datetime)
    end
  end
end
