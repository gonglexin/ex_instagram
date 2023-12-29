defmodule ExInstagram.Repo do
  use Ecto.Repo,
    otp_app: :ex_instagram,
    adapter: Ecto.Adapters.Postgres
end
