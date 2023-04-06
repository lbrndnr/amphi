defmodule Amphi.Models.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    belongs_to :user, Amphi.Models.User
    belongs_to :post, Amphi.Models.Post
    belongs_to :responses, Amphi.Models.Comment
    field :likes, :integer, default: 0
    field :text, :string

    timestamps()
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:likes, :text])
    |> validate_required([:likes, :text])
  end
end
