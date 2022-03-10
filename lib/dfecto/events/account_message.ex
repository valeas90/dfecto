defmodule Doomanager.Events.AccountMessage do
  @moduledoc """
  Message payload definition for account actions
  """
  alias Doomanager.SearchEngines.SearchEngine

  @derive Jason.Encoder
  defstruct [
    :code,
    :id,
    :query_limit_reached,
    :temporarily_disabled,
    searchengines: []
  ]

  @type t :: %__MODULE__{
          code: binary(),
          id: integer(),
          query_limit_reached: boolean(),
          temporarily_disabled: boolean(),
          searchengines: list(SearchEngine.t())
        }
end
