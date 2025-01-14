defmodule Squeeze.Utils do
  @moduledoc """
  Utility functions
  """

  def key_to_atom(map) do
    Enum.reduce(map, %{}, fn
      # String.to_existing_atom saves us from overloading the VM by
      # creating too many atoms. It'll always succeed because all the fields
      # in the database already exist as atoms at runtime.
      {key, value}, acc when is_atom(key) -> Map.put(acc, key, value)
      {key, value}, acc when is_binary(key) -> Map.put(acc, String.to_existing_atom(key), value)
    end)
  end

  def random_float(a, b), do: a + (b - a) * :rand.uniform()

  def random_int(a, b), do: a + :rand.uniform(b - a)

  def cast_float(nil), do: nil
  def cast_float(x) when is_integer(x), do: x * 1.0
  def cast_float(x), do: x
end
