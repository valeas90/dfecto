defmodule Dfecto.LiveLayer.Context do
  @moduledoc """
  The LiveLayer context.
  """
  import Ecto.Query, warn: false

  alias Doomanager.LiveLayer.Installation
  alias Doomanager.LiveLayer.Layer
  alias Doomanager.LiveLayer.Schemas.Installation, as: InstallationSchema
  alias Doomanager.LiveLayer.Schemas.Layer, as: LayerSchema
  alias Doomanager.LiveLayer.Schemas.Screen, as: ScreenSchema
  alias Doomanager.LiveLayer.Screen

  @cdn_prefix "https://cdn.doofinder.com/livelayer/1"

  @typedoc """
  Defines the schema of layer parameters. This is the structure needed by `Doomanager.LiveLayer`
  to save a layer, and its screen.

  ## Example

      %{
        css: %{
          "desktop" => "<p>No results...",
          "mobile" => "<p>No results..."
        },
        screen: %{
          "Elixir.LayerWeb.Layers.Fullscreen" => %{options: %{"min_capture_length" => 1}},
          "Elixir.LayerWeb.Layers.Mobile" => %{options: %{"min_capture_length" => 3}}
        }
      }
  """
  @type layer_params :: %{
          atom => any,
          :screen => %{
            (screen_type :: binary) => %{atom => any}
          }
        }

  @doc """
  Creates a complete Live Layer which includes the creation
  of Layer, Screen and Installation.

  ## Parameters
    - installation_config

  ## Response
    - {:ok, layer}
    - {:error, message}
    - {:unauthorized, message}

  """
  @spec create(map()) :: {:error, any()} | {:unauthorized, any()} | {:ok, map()}
  def create(
        %{
          account_id: account_id,
          layer_id: layer_id
        } = data
      ) do
    with layer when not is_nil(layer) <- Layer.get(layer_id),
         ^account_id <- layer.account_id,
         {:ok, installation} <- Installation.create(data) do
      {:ok, installation_script(installation)}
    else
      {:error, _} -> {:error, "Installation error"}
      _ -> {:unauthorized, "This account does not have the specified layer"}
    end
  end

  def create(
        %{
          account_id: account_id,
          name: name,
          layer_type: layer_type
        } = data
      ) do
    with {:ok, layer} <- Layer.create_layer_with_screens(layer_type, account_id, name),
         data <- Map.put(data, :layer_id, layer.id),
         {:ok, installation} <- Installation.create(data) do
      {:ok, installation_script(installation)}
    else
      _ ->
        {:error, "Installation error"}
    end
  end

  @doc """
  Returns the script.
  """
  @spec get_script(InstallationSchema.t()) :: String.t()
  def get_script(installation) do
    zone = Application.get_env(:doomanager, :aws_doof_zone)

    ~s"""
    <script>
      const dfLayerOptions = {
        installationId: '#{installation.id}',
        zone: '#{zone}'
      };

      (function (l, a, y, e, r, s) {
        r = l.createElement(a); r.onload = e; r.async = 1; r.src = y;
        s = l.getElementsByTagName(a)[0]; s.parentNode.insertBefore(r, s);
      })(document, 'script', '#{@cdn_prefix}/js/loader.min.js', function () {
        doofinderLoader.load(dfLayerOptions);
      });
    </script>
    """
  end

  @doc """
  Updates a Layer from a map containing the changes.
  """
  @spec save_layer(layer_params(), LayerSchema.t()) :: :ok | {:error, Ecto.Changeset.t()}
  def save_layer(params, layer) do
    {screens, params} = Map.pop(params, :screen)
    screens_map = map_screens(layer)

    with :ok <- save_layer_screens(screens, screens_map),
         {:ok, _schema} <- Layer.update(layer, params) do
      :ok
    end
  end

  @spec get_installation_script(pos_integer, binary) ::
          {:not_found, any()} | {:ok, map()} | {:unauthorized, any}
  def get_installation_script(account_id, id) do
    with installation when not is_nil(installation) <- Installation.get(id),
         ^account_id <- installation.account_id do
      {:ok, installation_script(installation)}
    else
      nil -> {:not_found, "Installation not found"}
      _ -> {:unauthorized, "This account does not have the specified installation"}
    end
  end

  @spec save_layer_screens(%{binary => %{atom => any}}, %{binary => ScreenSchema.t()}) ::
          :ok | {:error, Ecto.Changeset.t()}
  defp save_layer_screens(screens_params, screens) do
    Enum.reduce_while(screens_params, :ok, fn {type, screen_params}, _acc ->
      screen = Map.get(screens, type)

      case Screen.update(screen, screen_params) do
        {:ok, _schema} -> {:cont, :ok}
        err -> {:halt, err}
      end
    end)
  end

  @spec map_screens(LayerSchema.t()) :: %{binary => ScreenSchema.t()}
  defp map_screens(%_{screen: screens}), do: Enum.reduce(screens, %{}, &Map.put(&2, &1.type, &1))

  @spec installation_script(InstallationSchema.t()) :: map()
  defp installation_script(installation) do
    %{
      installation_id: installation.id,
      id: installation.id,
      account_id: installation.account_id,
      name: installation.name,
      config: installation.config,
      inserted_at: installation.inserted_at,
      updated_at: installation.updated_at,
      layer_id: installation.layer_id,
      script: get_script(installation)
    }
  end
end
