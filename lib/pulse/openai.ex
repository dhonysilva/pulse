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
        {_buffer, events} = parse([], data)
        Enum.each(events, callback)
        {:cont, acc}
      end
    )
  end

  defp set_stream(request, value) do
    request
    |> Map.drop([:stream, "stream"])
    |> Map.put("stream", value)
  end

  def parse(buffer, chunk) do
    parse(buffer, chunk, [])
  end

  defp parse([buffer | "\n"], "\n" <> rest, events) do
    case IO.iodata_to_binary(buffer) do
      "data: [DONE]" ->
        parse([], rest, events)

      "data: " <> event ->
        parse([], rest, [Jason.decode!(event) | events])
    end
  end

  defp parse(buffer, <<char::utf8, rest::binary>>, events) do
    parse([buffer | <<char::utf8>>], rest, events)
  end

  defp parse(buffer, "", events) do
    {buffer, Enum.reverse(events)}
  end

  defp api_key() do
    Application.get_env(:pulse, :openai)[:api_key]
  end
end
