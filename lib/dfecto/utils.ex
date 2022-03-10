defmodule Dfecto.Utils do
  @moduledoc """
  Shared utils to be used along the Dfecto app
  """

  @doc """
  Creates a identifier of the length given.
  """
  @spec generate_token(integer) :: binary
  def generate_token(length \\ 30) do
    length
    |> div(2)
    |> :crypto.strong_rand_bytes()
    |> Base.encode16(case: :lower)
  end
end
