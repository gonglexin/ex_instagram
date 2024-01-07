defmodule ExInstagram.LogsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExInstagram.Logs` context.
  """

  @doc """
  Generate a log.
  """
  def log_fixture(attrs \\ %{}) do
    {:ok, log} =
      attrs
      |> Enum.into(%{
        emoji: "some emoji",
        event: "some event",
        message: "some message"
      })
      |> ExInstagram.Logs.create_log()

    log
  end
end
