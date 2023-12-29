defmodule ExInstagram.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :name, :string
    field :language, :string
    field :vibe, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :language, :vibe])
    |> validate_required([:name, :vibe])
  end
end
