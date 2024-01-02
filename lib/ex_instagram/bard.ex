defmodule ExInstagram.Bard do
  @base_uri "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=#{System.get_env("GOOGLE_AI_API_KEY")}"

  def gen_caption(vibe, language \\ "English") do
    body = %{
      contents: [
        %{
          parts: [%{text: "Tweet about #{vibe} in #{language}"}]
        }
      ]
    }

    {:ok, resp} = Req.post(@base_uri, json: body)

    text =
      resp.body["candidates"]
      |> List.first()
      |> Map.get("content")
      |> Map.get("parts")
      |> List.first()
      |> Map.get("text")

    {:ok, text}
  end
end
