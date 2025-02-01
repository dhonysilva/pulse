defmodule Pulse.Openai do
  @chat_completions_url "https://api.openai.com/v1/chat/completions"

  def chat_completion(request) do
    Req.post(@chat_completions_url,
      json: set_stream(request, false),
      auth: {:bearer, api_key()}
    )
  end

  def chat_completion(request, callback) do
    Req.post(@chat_completions_url,
      json: set_stream(request, true),
      auth: {:bearer, api_key()},
      into: fn {:data, data}, acc ->
        Enum.each(parse(data), callback)
        {:cont, acc}
      end
    )
  end

  defp set_stream(request, value) do
    request
    |> Map.drop([:stream, "stream"])
    |> Map.put("stream", value)
  end

  defp parse(chunck) do
    chunck
    |> String.split("data: ")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&decode/1)
    |> Enum.reject(&is_nil/1)
  end

  defp decode(""), do: nil
  defp decode("[DONE]"), do: nil
  defp decode(data), do: Jason.decode!(data)

  defp api_key() do
    Application.get_env(:pulse, :openai)[:api_key]
  end
end
