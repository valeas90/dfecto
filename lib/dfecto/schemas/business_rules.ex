defmodule Dfecto.Schemas.BusinessRules do
  @moduledoc """
  The BusinessRule schema.
  """

  use Ecto.Schema

  import Ecto.Changeset

  alias Dfecto.Schemas.Banner
  alias Dfecto.Schemas.SearchEngine
  alias Dfecto.Utils.Ecto.ListMapField

  @fields [
    :name,
    :start_date,
    :end_date,
    :terms_data,
    :search_engine_id
  ]

  @derive {Jason.Encoder, only: @fields}

  @required_fields [:name, :terms_data]

  @type t :: %__MODULE__{
          name: binary,
          start_date: Date.t(),
          end_date: Date.t(),
          terms_data: list,
          search_engine_id: integer
        }

  schema "search_engines_businessrules" do
    field :name, :string
    field :start_date, :date
    field :end_date, :date
    field :terms_data, ListMapField, default: []

    has_one :banner, Banner
    belongs_to :search_engine, SearchEngine
  end

  @doc false
  @spec changeset(Ecto.Schema.t(), map) :: Ecto.Changeset.t()
  def changeset(business_rules, attrs) do
    business_rules
    |> cast(attrs, @fields)
    |> validate_length(:name, max: 255)
    |> validate_required(@required_fields)
    |> validate_dates
  end

  @spec validate_dates(Ecto.Changeset.t()) :: Ecto.Changeset.t()
  defp validate_dates(changeset) do
    start_date = get_field(changeset, :start_date)
    end_date = get_field(changeset, :end_date)

    if compare_date(start_date, end_date) do
      add_error(changeset, :start_date, "cannot be later than 'end_date'")
    else
      changeset
    end
  end

  @spec compare_date(Date.t(), Date.t()) :: boolean
  defp compare_date(start_date, end_date) when not is_nil(start_date) and not is_nil(end_date),
    do: Date.compare(start_date, end_date) == :gt

  defp compare_date(_, _), do: false
end
