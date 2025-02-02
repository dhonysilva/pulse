defmodule Pulse.OpenaiTest do
  use Pulse.DataCase

  alias Pulse.Openai

  test "can parse complete chunks" do
    event_one = %{
      "choices" => [
        %{
          "delta" => %{"content" => "Hello"},
          "finish_reason" => nil,
          "index" => 0,
          "logprobs" => nil
        }
      ],
      "created" => 1_704_745_461,
      "id" => "chatcmpl-8eqSTjwUmipuvL2s8CzjmXd1dTS08",
      "model" => "gpt-3.5-turbo-0613",
      "object" => "chat.completion.chunk",
      "system_fingerprint" => nil
    }

    event_two = %{
      "choices" => [
        %{
          "delta" => %{"content" => "!"},
          "finish_reason" => nil,
          "index" => 0,
          "logprobs" => nil
        }
      ],
      "created" => 1_704_745_461,
      "id" => "chatcmpl-8eqSTjwUmipuvL2s8CzjmXd1dTS08",
      "model" => "gpt-3.5-turbo-0613",
      "object" => "chat.completion.chunk",
      "system_fingerprint" => nil
    }

    chunk = """
    data: #{Jason.encode!(event_one)}

    data: #{Jason.encode!(event_two)}

    data: [DONE]

    """

    assert {[], [^event_one, ^event_two]} = Openai.parse([], chunk)
  end
end
