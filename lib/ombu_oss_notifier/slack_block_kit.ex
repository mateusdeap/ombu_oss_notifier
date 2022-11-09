defmodule OmbuOssNotifier.SlackBlockKit do
  
  # I honestly don't know a better way to do this since
  # in some cases we may be piping the results of iterators
  # into blocks
  def blocks(content) when is_list(content) do
    %{"blocks" => content}
  end
  def blocks(content), do: %{"blocks" => [content]}

  def add_element_to(element, content \\ []) do
    List.insert_at(content, -1, element)
  end

  def link_button(content \\ [], link_text, button_text, value, url) do
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
    } |> add_element_to(content)
  end

  def section(content \\ [], text) do
    %{
      "type" => "section",
      "text" => %{
        "type" => "mrkdwn",
        "text" => text
      }
    } |> add_element_to(content)
  end

  def divider(content \\ []) do
    %{
      "type" => "divider"
    } |> add_element_to(content)
  end
end
