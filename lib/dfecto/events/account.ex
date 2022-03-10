defmodule Doomanager.Events.Account do
  @moduledoc """
  Module defining Account events consumer functions.
  """

  alias DoomanagerWeb.GoogleAnalytics

  @spec consume_event(map()) :: :ok
  def consume_event(%{"action" => "created", "payload" => %{"code" => code}}) do
    send_analytics_signup_event(code)
    :ok
  end

  def consume_event(%{"action" => _}), do: :ok

  @spec send_analytics_signup_event(binary()) :: :ok | {:error, atom()} | nil
  defp send_analytics_signup_event(client_id) do
    if Application.get_env(:doomanager, :env) == :prod do
      GoogleAnalytics.send_event(:web, client_id, "signup", "auth")
    end
  end
end
