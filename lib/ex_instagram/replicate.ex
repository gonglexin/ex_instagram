defmodule ExInstagram.Replicate do
  def gen_image(image_prompt) do
    # model = Replicate.Models.get!("stability-ai/stable-diffusion")
    model = Replicate.Models.get!("stability-ai/sdxl")

    version =
      Replicate.Models.get_version!(
        model,
        "39ed52f2a78e934b3ba6e2a89f5b1c712de7dfea535525255b1aa35c5565e08b"
      )

    {:ok, prediction} = Replicate.Predictions.create(version, %{prompt: image_prompt})
    {:ok, prediction} = Replicate.Predictions.wait(prediction)

    prediction.output
    |> List.first()
    |> IO.inspect()
    |> save_image(prediction.id)
  end

  def save_image(url, uuid) do
    image_binary = Req.get!(url).body

    file_name = "#{uuid}.png"
    bucket = System.get_env("AWS_BUCKET")

    %{status_code: 200} =
      ExAws.S3.put_object(bucket, file_name, image_binary)
      |> ExAws.request!()

    {:ok, "#{System.get_env("CLOUDFLARE_PUBLIC_URL")}/#{file_name}"}
  end
end
