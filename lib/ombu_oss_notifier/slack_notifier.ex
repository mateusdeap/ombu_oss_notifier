defmodule OmbuOssNotifier.SlackNotifier do
  alias OmbuOssNotifier.SlackBlockKit

  @post_message_url "https://slack.com/api/chat.postMessage"

  def notify(%{"message" => message}) do
    SlackBlockKit.section(message)
    |> SlackBlockKit.blocks()
    |> add_channel()
    |> Poison.encode!()
    |> post_to_slack()
  end  
  def notify(issues) do
    Enum.map(issues, fn issue -> SlackBlockKit.link_button(issue.title, "Github", issue.url, issue.url) end)
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
