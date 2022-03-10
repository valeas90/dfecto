defmodule Dfecto.EctoUtils.ListMapField do
  @moduledoc """
  Ecto field to store a list of maps inside a text field in database (json format)
  """

  use Ecto.Type

  @spec type() :: :string
  def type, do: :string

  @spec cast(binary) :: :error | {:ok, any()}
  def cast(string_value) when is_binary(string_value) do
    with {:ok, value} = res <- Jason.decode(string_value),
         true <- is_list_map_type?(value) do
      res
    else
      _ -> :error
    end
  end

  def cast(values) do
    case is_list_map_type?(values) do
      true -> {:ok, values}
      false -> :error
    end
  end

  @spec load(binary) :: :error | {:ok, binary}
  def load(data) when is_binary(data), do: Jason.decode(data)

  @spec dump(list) :: :error | {:ok, binary}
  def dump(values) do
    case is_list_map_type?(values) do
      true -> Jason.encode(values)
      false -> :error
    end
  end

  @spec is_list_map_type?(any) :: boolean
  defp is_list_map_type?(values) when is_list(values), do: Enum.all?(values, &is_map/1)
  defp is_list_map_type?(_), do: false
end
