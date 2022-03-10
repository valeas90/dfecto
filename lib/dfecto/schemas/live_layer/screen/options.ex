defmodule Dfecto.Schemas.LiveLayer.Screen.Options do
  @moduledoc """
  `Options` module handles the schemas available for `Screen` options field.

  Each screen type have a different set of options. For instance, "MobileInitial"
  does not make use of the "suggestions" options. This modules link every type
  with their schema. If an option is not defined in a schema, the option is
  discarded. If there is no specific schema for the screen type, all options
  are discarded.
  """

  import Ecto.Changeset,
    only: [add_error: 3, apply_changes: 1, cast: 3, get_field: 2, put_change: 3]

  alias Dfecto.Schemas.LiveLayer.Screen.Options
  alias Ecto.Changeset

  @type_options %{
    "Elixir.LayerWeb.Layers.Classic" => Options.Classic,
    "Elixir.LayerWeb.Layers.Embedded" => Options.Embedded,
    "Elixir.LayerWeb.Layers.Fullscreen" => Options.Fullscreen,
    "Elixir.LayerWeb.Layers.FullscreenInitial" => Options.FullscreenInitial,
    "Elixir.LayerWeb.Layers.Mobile" => Options.Mobile,
    "Elixir.LayerWeb.Layers.MobileInitial" => Options.MobileInitial
  }

  @doc """
  Casts a screen options embed schema with the changeset parameters.
  """
  @spec cast_embed(Changeset.t()) :: Changeset.t()
  def cast_embed(changeset) do
    case type_module(changeset) do
      nil ->
        put_change(changeset, :options, %{})

      opts_module ->
        opts_changeset =
          changeset
          |> get_field(:options)
          |> cast_all(opts_module)

        if opts_changeset.valid? do
          options = apply(opts_changeset)
          put_change(changeset, :options, options)
        else
          # TODO; add options changeset errors to the main changeset.
          add_error(changeset, :options, "is invalid")
        end
    end
  end

  @spec apply(Changeset.t()) :: %{atom => term}
  defp apply(changeset) do
    changeset
    |> apply_changes()
    |> Map.from_struct()
  end

  # TODO; Options validations are very simple right now. If we need that some
  # screen options have more specific validations, we can define a changeset
  # function for those modules, and use `module.__info__(:functions)` or
  # `function_exported?/3` to check if they have a custom changeset defined. If
  # they have, we will use it. If not, we wil use the `cast_all` function.
  @spec cast_all(map, module) :: Changeset.t()
  defp cast_all(options, opts_module) do
    fields = opts_module.__schema__(:fields)
    cast(struct(opts_module), options, fields)
  end

  @spec type_module(Changeset.t()) :: module
  defp type_module(changeset) do
    changeset
    |> get_field(:type)
    |> (&Map.get(@type_options, &1)).()
  end
end
