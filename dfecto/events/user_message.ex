defmodule Doomanager.Events.UserMessage do
  @moduledoc """
  Message payload definition for user actions
  """
  alias Doomanager.Accounts.Account
  alias Doomanager.MyTokens.MyToken
  alias Doomanager.SearchEngines.SearchEngine

  @derive Jason.Encoder
  defstruct [
    :account,
    :role,
    :id,
    :username,
    tokens: [],
    search_engines: []
  ]

  @type t :: %__MODULE__{
          account: Account.t(),
          role: binary(),
          id: integer(),
          username: binary(),
          tokens: list(MyToken.t()),
          search_engines: list(SearchEngine.t())
        }
end
