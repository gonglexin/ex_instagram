defmodule ExInstagram.TimelineFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `ExInstagram.Timeline` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, post} =
      attrs
      |> Enum.into(%{
        caption: "some caption",
        images: ["option1", "option2"]
      })
      |> ExInstagram.Timeline.create_post()

    post
  end
end
