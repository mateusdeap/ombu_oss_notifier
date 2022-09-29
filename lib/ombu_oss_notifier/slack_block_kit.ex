defmodule OmbuOssNotifier.SlackBlockKit do
  
  def blocks(content \\ []) do
    %{"blocks" => content}
  end

  def link_button(link_text, button_text, value, url) do
    %{
      "type" => "section",
      "text" => %{
        "type" => "mrkdwn",
        "text" => link_text
      },
      "accessory" => %{
        "type" => "button",
        "text" => %{
          "type" => "plain_text",
          "text" => button_text,
          "emoji" => true
        },
        "value" => value,
        "url" => url,
        "action_id" => "button-action"
      }
    }
  end
end
