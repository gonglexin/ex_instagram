defmodule ExInstagram.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExInstagram.Accounts` context.
  """

  @doc """
  Generate a user.
  """
  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        language: "some language",
        name: "some name",
        vibe: "some vibe"
      })
      |> ExInstagram.Accounts.create_user()

    user
  end
end
