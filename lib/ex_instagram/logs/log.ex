defmodule ExInstagram.Logs.Log do
  use Ecto.Schema
  import Ecto.Changeset

  schema "logs" do
    field :message, :string
    field :event, :string
    field :emoji, :string

    belongs_to :user, ExInstagram.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(log, attrs) do
    log
    |> cast(attrs, [:user_id, :event, :emoji, :message])
    |> validate_required([:event, :emoji, :message])
  end
end
