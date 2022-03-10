defmodule Dfecto.LiveLayer.Schemas.Screen.Params do
  @moduledoc """
  `Params` module handles the schemas available for `Screen` parameters field.

  Each screen type have a different set of parameters. For instance, "MobileInitial"
  does not make use of any parameters. This modules link every type with their
  schema. If a parameter is not defined in a schema, the parameter is
  discarded. If there is no specific schema for the screen type, all parameters
  are discarded.

  Parameters is not a common embed schema, it is a map where each key
  represents an index name (where "" means all indices), and the value is the
  actual schema of the parameter. This module handle the validation of that
  "inner" schema.
  """

  import Ecto.Changeset,
    only: [add_error: 3, apply_changes: 1, cast: 3, get_change: 2, get_field: 2, put_change: 3]

  alias Dfecto.LiveLayer.Schemas.Screen.Params
  alias Ecto.Changeset

  @type_params %{
    "Elixir.LayerWeb.Layers.Classic" => Params.Classic,
    "Elixir.LayerWeb.Layers.Embedded" => Params.Embedded,
    "Elixir.LayerWeb.Layers.Fullscreen" => Params.Fullscreen
  }

  @doc """
  Casts a screen parameters embed schema with the changeset parameters.
  """
  @spec cast_embed(Changeset.t()) :: Changeset.t()
  def cast_embed(changeset) do
    case type_module(changeset) do
      nil ->
        put_change(changeset, :params, %{})

      params_module ->
        params_changesets =
          changeset
          |> get_field(:params)
          |> cast_all(params_module)

        changeset = put_change(changeset, :params, %{})

        Enum.reduce_while(params_changesets, changeset, fn {index, index_changeset}, changeset ->
          if index_changeset.valid? do
            index_params = apply(index_changeset)

            params =
              changeset
              |> get_change(:params)
              |> Map.update(index, index_params, &Map.merge(&1, index_params))

            {:cont, put_change(changeset, :params, params)}
          else
            # TODO; add params changeset errors to the main changeset.
            {:halt, add_error(changeset, :params, "is invalid")}
          end
        end)
    end
  end

  @spec apply(Changeset.t()) :: %{atom => term}
  defp apply(changeset) do
    changeset
    |> apply_changes()
    |> Map.from_struct()
  end

  # TODO; Params validations are very simple right now. If we need that some
  # screen params have more specific validations, we can define a changeset
  # function for those modules, and use `module.__info__(:functions)` or
  # `function_exported?/3` to check if they have a custom changeset defined. If
  # they have, we will use it. If not, we wil use the `cast_all` function.
  @spec cast_all(map, module) :: [{binary, Changeset.t()}]
  defp cast_all(params, params_module) do
    fields = params_module.__schema__(:fields)

    Enum.map(params, fn {index, index_params} ->
      {index, cast(struct(params_module), index_params, fields)}
    end)
  end

  @spec type_module(Changeset.t()) :: module
  defp type_module(changeset) do
    changeset
    |> get_field(:type)
    |> (&Map.get(@type_params, &1)).()
  end
end
