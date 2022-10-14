defmodule OmbuOssNotifier.Fastruby do
  @moduledoc """
  The Fastruby context.
  """

  import Ecto.Query, warn: false
  alias OmbuOssNotifier.Repo

  alias OmbuOssNotifier.Fastruby.Issue

  @expected_fields ~w(title html_url)
  @expected_repo_fields ~w(name)
  @expected_repos ~w(next_rails skunk)

  @doc """
  Returns the list of issues.

  ## Examples

      iex> list_issues()
      [%Issue{}, ...]
  """

  def list_issues do
    page = 1
    headers = [
      "Accept": "application/vnd.github+json"
    ]
    repos_url = "https://api.github.com/orgs/fastruby/repos"
    HTTPoison.start
    get_org_repos(repos_url, headers, page)
    |> get_org_issues(headers)
  end

  defp get_org_repos(repos_url, headers, page, repos \\ []) do
    page_repos = HTTPoison.get!(repos_url <> "?page=#{page}", headers).body
    |> Poison.decode!

    case page_repos do
      [] -> repos
      %{"message" => message} -> %{"message" => message}
      _ -> get_org_repos(repos_url, headers, page + 1, Enum.concat(repos, page_repos))
    end
  end

  defp get_org_issues(%{"message" => message}, _), do: %{"message" => message}
  defp get_org_issues(repos, headers) do
    repos
    |> Enum.map(fn(repo_map) -> Map.take(repo_map, @expected_repo_fields) end)
    |> Enum.filter(fn(repo) -> Enum.member?(@expected_repos, repo["name"]) end)
    |> Enum.flat_map(fn repo -> get_repo_issues(repo["name"], headers) end)
  end

  defp get_repo_issues(repo, headers) do
    issues_url = "https://api.github.com/repos/fastruby/#{repo}/issues?labels=bug"
    HTTPoison.get!(issues_url, headers).body
    |> Poison.decode!
    |> Enum.map(fn(map) -> Map.take(map, @expected_fields) end)
    |> Enum.map(fn(map) -> %Issue{title: map["title"], url: map["html_url"]} end)
  end
end
