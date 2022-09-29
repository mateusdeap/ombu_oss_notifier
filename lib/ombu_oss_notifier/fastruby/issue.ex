defmodule OmbuOssNotifier.Fastruby.Issue do
  use Ecto.Schema
  import Ecto.Changeset

  schema "issues" do
    field :title, :string
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(issue, attrs) do
    issue
    |> cast(attrs, [:title, :url])
    |> validate_required([:title, :url])
  end
end
