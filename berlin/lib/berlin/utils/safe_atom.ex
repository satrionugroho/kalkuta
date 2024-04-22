defmodule Berlin.Utils.SafeAtom do
  @spec to_atom(string :: String.t()) :: atom() | {:error, message :: String.t()}
  def to_atom(string) when is_atom(string), do: string
  def to_atom(string) when is_bitstring(string) do
    try do
      String.to_existing_atom(string)
    rescue ArgumentError ->
      String.to_atom(string)
    end
  end
  def to_atom(string), do: {:error, "cannot parse #{inspect string} to atom equivalent"}
end
