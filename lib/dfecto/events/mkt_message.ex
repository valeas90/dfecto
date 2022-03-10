defmodule Doomanager.Events.MktMessage do
  @moduledoc """
  Message payload definition for marketing actions
  """

  @derive Jason.Encoder
  defstruct [
    :account_code,
    mktcod: ""
  ]

  @type t :: %__MODULE__{
          account_code: binary(),
          mktcod: binary()
        }
end
