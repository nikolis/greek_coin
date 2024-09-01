defmodule GreekCoin.Localization.Language do
  use Ecto.Schema
  import Ecto.Changeset

  alias GreekCoin.Localization.Country

  schema "languages" do
    field :tag, :string
    field :title, :string
   
    belongs_to :country, Country 
    timestamps()
  end

  @doc false
  def changeset(language, attrs) do
    language
    |> cast(attrs, [:title, :tag])
    |> validate_required([:title, :tag])
  end
end
