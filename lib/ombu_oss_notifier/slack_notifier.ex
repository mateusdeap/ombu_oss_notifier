defmodule OmbuOssNotifier.SlackNotifier do
  alias OmbuOssNotifier.SlackBlockKit
  
  def notify(issues) do
    slack_bot_url = "https://hooks.slack.com/services/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"
    headers = [
      "Content-type": "application/json"
    ]

    payload = Enum.map(issues, fn issue -> SlackBlockKit.link_button(issue.title, "Github", issue.url, issue.url) end)
    |> SlackBlockKit.blocks()
    |> Poison.encode!()

    HTTPoison.post(slack_bot_url, payload, headers)
  end
end
