ExUnit.start

defmodule ExceteraTest.Helpers do
  def cleanup(root) do
    case Excetera.API.delete root, [recursive: true], decode_body: false do
      {:ok, _} -> :ok
      {:error, 404} -> :ok
      other -> other
    end
  end
end
