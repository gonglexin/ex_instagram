defmodule ExInstagram.Bard do
  require Logger
  @base_uri "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent"

  def gen_caption(vibe, language \\ "English") do
    body = %{
      contents: [
        %{
          parts: [%{text: "Tweet about #{vibe} in #{language}"}]
        }
      ]
    }

    resp = Req.post!(@base_uri <> "?key=#{System.get_env("GOOGLE_AI_API_KEY")}", json: body)

    Logger.info(inspect(resp))

    text =
      resp.body["candidates"]
      |> List.first()
      |> Map.get("content")
      |> Map.get("parts")
      |> List.first()
      |> Map.get("text")

    {:ok, text}
  end

  def gen_avatar(vibe) do
    body = %{
      contents: [
        %{
          parts: [
            %{
              text:
                "Based on a user whose vibes are #{vibe}, generate an avatar description for he/she"
            }
          ]
        }
      ]
    }

    resp = Req.post!(@base_uri <> "?key=#{System.get_env("GOOGLE_AI_API_KEY")}", json: body)

    Logger.info(inspect(resp))

    text =
      resp.body["candidates"]
      |> List.first()
      |> Map.get("content")
      |> Map.get("parts")
      |> List.first()
      |> Map.get("text")

    ExInstagram.Replicate.gen_image(text)
  end
end
