defmodule Dfecto.Schemas.AuthGroup do
  @moduledoc """
  The AuthGroup schema.
  """

  use Ecto.Schema

  @type t :: %__MODULE__{
          name: binary
        }

  schema "auth_group" do
    field(:name, :string)
  end
end
