defmodule Doomanager.LiveLayer.Layer do
  @moduledoc """
  Module for managing Layers
  """
  import Ecto.Query, warn: false

  alias Doomanager.Events
  alias Doomanager.LiveLayer.Colors
  alias Doomanager.LiveLayer.Queries.Layer, as: LayerQuery
  alias Doomanager.LiveLayer.Schemas.Layer, as: LayerSchema
  alias Doomanager.LiveLayer.Schemas.Screen, as: ScreenSchema
  alias Doomanager.Repo

  alias Ecto.Multi

  @accent_colors [:accent_primary, :accent_secondary, :accent_tertiary]
  @card_flag_colors [
    :card_flag_in_stock_background,
    :card_flag_in_stock_color,
    :card_flag_discount_background,
    :card_flag_discount_color
  ]
  @neutral_colors [
    :neutral_background,
    :neutral_surface,
    :neutral_surface_variant,
    :neutral_outline,
    :neutral_medium_contrast,
    :neutral_high_contrast
  ]

  @doc """
  Returns the list of layers.
  """
  @spec list(pos_integer) :: [LayerSchema.t()]
  def list(account_id) do
    account_id
    |> LayerQuery.for_account()
    |> Repo.all()
  end

  @doc """
  Gets a single layer.

  Raises `Ecto.NoResultsError` if the Layer does not exist.

  """
  @spec get!(any) :: LayerSchema.t()
  def get!(id), do: Repo.get!(LayerSchema, id)

  @doc """
  Gets a single layer.

  Returns nil if the Layer does not exist.

  """
  @spec get(pos_integer()) :: LayerSchema.t() | nil
  def get(id), do: Repo.get(LayerSchema, id)

  @doc """
  Creates a layer.
  """
  @spec create(map) :: {:ok, LayerSchema.t() | {:error, Ecto.Changeset.t() | any()}}
  def create(attrs \\ %{}) do
    Repo.transaction(fn ->
      created_layer =
        %LayerSchema{}
        |> LayerSchema.changeset(attrs)
        |> Repo.insert()

      with {:ok, layer} <- created_layer,
           :ok <- Events.trigger_event(layer, :created) do
        layer
      else
        {:error, error} ->
          Repo.rollback(error)
      end
    end)
  end

  @doc """
  Updates a layer.
  """
  @spec update(LayerSchema.t(), map) ::
          {:ok, LayerSchema.t()} | {:error, Ecto.Changeset.t() | any()}
  def update(%LayerSchema{} = layer, attrs) do
    Repo.transaction(fn ->
      updated_layer =
        layer
        |> LayerSchema.changeset(attrs)
        |> Repo.update()

      with {:ok, layer} <- updated_layer,
           :ok <- Events.trigger_event(layer, :updated) do
        layer
      else
        {:error, error} ->
          Repo.rollback(error)
      end
    end)
  end

  @doc """
  Deletes a layer.
  """
  @spec delete(LayerSchema.t()) :: {:ok, LayerSchema.t()} | {:error, Ecto.Changeset.t() | any()}
  def delete(%LayerSchema{} = layer) do
    Repo.transaction(fn ->
      with {:ok, layer} <- Repo.delete(layer),
           :ok <- Events.trigger_event(layer, :deleted) do
        layer
      else
        {:error, error} ->
          Repo.rollback(error)
      end
    end)
  end

  @spec list_layers_with_screens :: [LayerSchema.t()]
  def list_layers_with_screens do
    query = from l in LayerSchema, preload: [:screen]
    Repo.all(query)
  end

  @doc """
  Creates a new layer with its corresponding screens.

  ## Parameters
    - layer_type: Layer type for example: 'TYPE_0' or 'TYPE_A'.
    - account_id: Account id.
    - name: Layer name, useful to identify it in the control panel.

  ## Response
    - {:ok, layer}
    - {:error, message}

  """
  @spec create_layer_with_screens(binary, pos_integer, binary) ::
          {:error, binary | Ecto.Changeset.t()} | {:ok, LayerSchema.t()}
  def create_layer_with_screens(layer_type, account_id, name) do
    result =
      Multi.new()
      |> Multi.insert(
        :layer,
        LayerSchema.changeset(%LayerSchema{}, %{
          account_id: account_id,
          name: name,
          type: layer_type
        })
      )
      |> Multi.insert_all(:screens, ScreenSchema, fn %{layer: layer} ->
        {:ok, params} = LayerSchema.screens_by_type(layer.type)
        Enum.map(params, &Map.put(&1, :layer_id, layer.id))
      end)
      |> Repo.transaction()

    case result do
      {:ok, %{layer: layer, screens: _screens}} ->
        {:ok, layer}

      {:error, failed_operation, fail_value, _changes_so_far} ->
        {:error, {failed_operation, fail_value}}
    end
  end

  @doc """
  Merges colors with computed colors per device
  """
  @spec merge_colors(binary, map, map, map) :: map
  def merge_colors(device, css, colors, computed_colors) do
    colors_map = %{
      "colors" => colors,
      "colors_computed" => computed_colors
    }

    Map.update(css, device, colors_map, &Map.merge(&1, colors_map))
  end

  @doc """
  Calculates dynamic css for the Live Layer.
  """
  @spec compute_colors(map | nil) :: binary
  def compute_colors(colors) when is_map(colors) do
    variables =
      colors
      |> Enum.map(fn {key, value} -> process_color(key, value) end)
      |> Map.new()

    @accent_colors
    |> Kernel.++(@neutral_colors)
    |> Kernel.++(@card_flag_colors)
    |> Enum.map(&Map.get(variables, &1))
    |> Enum.reject(&is_nil/1)
    |> List.flatten()
    |> Enum.join("\n")
  end

  def compute_colors(nil), do: ""

  @spec process_color(binary, binary) :: {binary, [binary]}
  defp process_color(color_key, color_hex) when color_key in @accent_colors do
    [hue, saturation, lightness] = Colors.hex_to_hsl(color_hex)

    color_type =
      color_key
      |> Atom.to_string()
      |> String.replace("accent_", "")
      |> String.replace("_", "-")

    on_color_hex = Colors.hsl_to_hex(hue, saturation, if(lightness > 70, do: 20, else: 98))
    hover_hex = Colors.hsl_to_hex(hue, saturation, max(0, lightness - 5))
    active_hex = Colors.hsl_to_hex(hue, saturation, max(0, lightness - 10))

    {color_key,
     [
       ~s(--df-accent-#{color_type}: #{color_hex};),
       ~s(--df-accent-#{color_type}-hover: #{hover_hex};),
       ~s(--df-accent-#{color_type}-active: #{active_hex};),
       ~s(--df-accent-on-#{color_type}: #{on_color_hex};)
     ]}
  end

  defp process_color(color_key, color_hex)
       when color_key in @neutral_colors or color_key in @card_flag_colors do
    color_type =
      color_key
      |> Atom.to_string()
      |> String.replace("_", "-")

    {color_key, [~s(--df-#{color_type}: #{color_hex};)]}
  end

  defp process_color(color_key, _color_hex), do: {color_key, [nil]}
end
