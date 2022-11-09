defmodule OmbuOssNotifier.SlackNotifier do
  alias OmbuOssNotifier.SlackBlockKit

  @post_message_url "https://slack.com/api/chat.postMessage"

  def notify(%{"message" => message}) do
    SlackBlockKit.section([], message)
    |> SlackBlockKit.blocks()
    |> add_channel()
    |> Poison.encode!()
    |> post_to_slack()
  end
  def notify([]) do
    SlackBlockKit.section([], "The Force in balance it is. Issues our attention they do not need.")
    |> SlackBlockKit.blocks()
    |> add_channel()
    |> Poison.encode!()
    |> post_to_slack()
  end  
  def notify(issues) do
    content = SlackBlockKit.section([], "I sense a disturbance in the force... these issues are slipping to the Dark Side...")
    |> SlackBlockKit.divider()

    Enum.reduce(issues, content, fn issue, acc -> SlackBlockKit.link_button(acc, issue.title, "Github", issue.url, issue.url) end)
    |> SlackBlockKit.blocks()
    |> add_channel()
    |> Poison.encode!()
    |> post_to_slack()
  end

  defp add_channel(content) do
    Map.new([{"channel", Application.fetch_env!(:ombu_oss_notifier, :channel_id)}])
    |> Map.merge(content)
  end

  defp post_to_slack(payload) do
    case HTTPoison.post(@post_message_url, payload, headers()) do
      {:ok, reponse} -> IO.puts("Message sent!")
      {:error, reason} -> IO.inspect(reason)
    end
  end

  defp headers() do
    [
      "Content-type": "application/json",
      "Authorization": "Bearer #{Application.fetch_env!(:ombu_oss_notifier, :slack_api_token)}"
    ]
  end
end
