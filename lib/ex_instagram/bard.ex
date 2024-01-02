defmodule ExInstagram.Bard do
  @base_uri "https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=#{System.get_env("GOOGLE_AI_API_KEY")}"

  def tweet(vibe, language \\ "English") do
    body = %{
      contents: [
        %{
          parts: [%{text: "Tweet about #{vibe} in #{language}"}]
        }
      ]
    }

    {:ok, resp} = Req.post(@base_uri, json: body)

    resp.body["candidates"]
    |> List.first()
    |> Map.get("content")
    |> Map.get("parts")
    |> List.first()
    |> Map.get("text")
  end
end
