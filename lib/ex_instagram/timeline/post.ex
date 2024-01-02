defmodule ExInstagram.Timeline.Post do
  use Ecto.Schema
  import Ecto.Changeset

  alias ExInstagram.Accounts.User

  schema "posts" do
    field :images, {:array, :string}
    field :caption, :string
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(post, attrs) do
    post
    |> cast(attrs, [:images, :caption])
    |> validate_required([:images, :caption])
  end
end
