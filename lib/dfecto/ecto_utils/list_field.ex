defmodule Dfecto.EctoUtils.ListField do
  @moduledoc """
  Ecto field to store list inside a text field in database (json format)
  """

  use Ecto.Type

  @spec type() :: :string
  def type, do: :string

  @spec cast(binary) :: :error | {:ok, any}
  def cast(string_value) when is_binary(string_value) do
    case Jason.decode(string_value) do
      {:ok, value} = res when is_list(value) -> res
      _ -> :error
    end
  end

  def cast(values) when is_list(values), do: values

  def cast(_), do: :error

  @spec load(binary) :: :error | {:ok, binary}
  def load(data) when is_binary(data), do: Jason.decode(data)

  @spec dump(list) :: :error | {:ok, binary}
  def dump(values) when is_list(values), do: Jason.encode(values)
  def dump(_), do: :error
end
