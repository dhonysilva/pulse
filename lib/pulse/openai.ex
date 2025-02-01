defmodule Pulse.Openai do
  @chat_completions_url "https://api.openai.com/v1/chat/completions"

  def chat_completion(request, callback) do
    Req.post(@chat_completions_url,
      json: request,
      auth: {:bearer, api_key()},
      into: fn {:data, data}, context ->
        callback.(data)
        {:cont, context}
      end
    )
  end

  defp api_key() do
    Application.get_env(:pulse, :openai)[:api_key]
  end
end
