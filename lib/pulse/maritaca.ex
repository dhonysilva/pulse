defmodule Pulse.Maritaca do
  @chat_maritaca_url "https://chat.maritaca.ai/api/"

  def chat_completion(request) do
    Req.post(@chat_maritaca_url,
      json: set_stream(request, false),
      auth: {:bearer, api_key()}
    )
  end

  def chat_completion(request, callback) do
    # Initialize buffer state
    {:ok, agent} = Agent.start_link(fn -> [] end)

    response =
      Req.post(@chat_maritaca_url,
        json: set_stream(request, true),
        auth: {:bearer, api_key()},
        into: fn {:data, data}, acc ->
          # Get previous buffer value
          buffer = Agent.get(agent, & &1)

          {buffer, events} = parse(buffer, data)
          Enum.each(events, callback)

          # Update buffer value with the result from calling parse/2
          :ok = Agent.update(agent, fn _ -> buffer end)

          {:cont, acc}
        end
      )

    # Make sure we shut the agent down
    :ok = Agent.stop(agent)

    response
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
    Application.get_env(:pulse, :maritaca)[:maritaca_api_key]
  end
end
