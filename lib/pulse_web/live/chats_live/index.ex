defmodule PulseWeb.ChatLive.Index do
  use PulseWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:messages, [])
      |> assign(:running, false)

    {:ok, socket}
  end

  def handle_event("submit", %{"content" => content}, socket) do
    message = %{role: :user, content: content}

    updated_messages = [message | socket.assigns.messages]

    pid = self()

    socket =
      socket
      |> assign(:running, true)
      |> assign(:messages, updated_messages)
      |> start_async(:chat_completion, fn ->
        run_chat_completion(pid, Enum.reverse(updated_messages))
      end)

    {:noreply, socket}
  end

  @impl true
  def handle_async(:chat_completion, _result, socket) do
    {:noreply, assign(socket, :running, false)}
  end

  @impl true
  def handle_info({:chunk, chunk}, socket) do
    updated_messages =
      case socket.assigns.messages do
        [%{role: :assistant, content: content} | messages] ->
          [%{role: :assistant, content: content <> chunk} | messages]

        messages ->
          [%{role: :assistant, content: chunk} | messages]
      end

    {:noreply, assign(socket, messages: updated_messages)}
  end

  defp run_chat_completion(pid, messages) do
    request = %{model: "gpt-4", temperature: 1, messages: messages}

    Pulse.Openai.chat_completion(request, fn chunk ->
      case chunk do
        %{"choices" => [%{"delta" => %{"content" => content}}]} ->
          send(pid, {:chunk, content})

        _ ->
          nil
      end
    end)
  end
end
