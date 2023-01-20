defmodule OmbuOssNotifier.SlackNotifier do
  alias OmbuOssNotifier.SlackBlockKit

  @post_message_url "https://slack.com/api/chat.postMessage"

  def notify(%{"message" => message}) do
    SlackBlockKit.section([], message)
    |> SlackBlockKit.blocks()
    |> do_notify()
  end

  def notify([]) do
    SlackBlockKit.section([], "In balance, the Force is. Our attention, the Issues do not need.")
    |> SlackBlockKit.blocks()
    |> do_notify()
  end

  def notify(issues) do
    content =
      SlackBlockKit.section(
        [],
        "A disturbance in the Force, I sense... turning to the Dark Side, these issues are..."
      )
      |> SlackBlockKit.divider()

    Enum.reduce(issues, content, fn issue, acc ->
      SlackBlockKit.link_button(acc, issue.title, "Github", issue.url, issue.url)
    end)
    |> SlackBlockKit.blocks()
    |> do_notify()
  end

  defp do_notify(content) do
    add_channel(content)
    |> add_username()
    |> add_icon()
    |> Poison.encode!()
    |> post_to_slack()
  end

  def add_username(content) do
    Map.new([{"username", "Master Yoda"}])
    |> Map.merge(content)
  end

  def add_icon(content) do
    Map.new([
      {"icon_url",
       "https://pbs.twimg.com/profile_images/3464665605/463d56a85545a3852fb4784ab947fba4_bigger.jpeg"}
    ])
    |> Map.merge(content)
  end

  defp add_channel(content) do
    Map.new([{"channel", Application.fetch_env!(:ombu_oss_notifier, :channel_id)}])
    |> Map.merge(content)
  end

  defp post_to_slack(payload) do
    case HTTPoison.post(@post_message_url, payload, headers()) do
      {:ok, _response} -> IO.puts("Message sent!")
      {:error, reason} -> IO.inspect(reason)
    end
  end

  defp headers() do
    [
      "Content-type": "application/json",
      Authorization: "Bearer #{Application.fetch_env!(:ombu_oss_notifier, :slack_api_token)}"
    ]
  end
end
