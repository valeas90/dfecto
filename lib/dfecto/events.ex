defmodule Dfecto.Events do
  @moduledoc """
  Module used to trigger events.
  """

  alias Dfecto.LiveLayer.Schemas.Installation
  alias Dfecto.LiveLayer.Schemas.Layer
  alias Dfecto.LiveLayer.Schemas.Screen

  @events_manager_module Application.compile_env!(:doomanager, :event_module)

  @event_type %{"layer" => "layer", "new_screen" => "screen", "installation" => "installation"}

  @accepted_actions [:created, :updated, :deleted]

  @typedoc """
  A schema that can trigger an event upon modificaton
  """
  @type payload :: Layer.t() | Screen.t() | Installation.t()

  @typedoc """
  An action that can trigger an event
  """
  @type action :: :created | :updated | :deleted

  @spec trigger_event(payload(), action()) :: :ok | {:error, any()}
  def trigger_event(%{:__meta__ => _} = payload, action) do
    case Map.fetch(@event_type, payload.__struct__.__schema__(:source)) do
      {:ok, event_type} ->
        trigger_event(payload, event_type, action)

      :error ->
        {:error, "Unsupported payload type"}
    end
  end

  def trigger_event(_, _), do: {:error, "Unsupported payload type"}

  @spec trigger_event(map(), String.t(), action()) :: :ok | {:error, any()}
  def trigger_event(payload, topic, action) do
    with {:ok, message} <- form_message(payload, topic, action),
         {:ok, encoded_message} <- Jason.encode(message) do
      @events_manager_module.broadcast(topic, encoded_message)
    end
  end

  @spec form_message(map(), String.t(), action()) :: {:ok, map()} | {:error, any()}
  defp form_message(payload, topic, action) when action in @accepted_actions do
    {
      :ok,
      %{
        "action" => Atom.to_string(action),
        "object" => topic,
        "timestamp" => get_timestamp(),
        "payload" => payload
      }
    }
  end

  defp form_message(_, _, action), do: {:error, "#{action} is not a valid action"}

  @spec get_timestamp :: String.t()
  defp get_timestamp do
    DateTime.to_iso8601(DateTime.utc_now())
  end
end
