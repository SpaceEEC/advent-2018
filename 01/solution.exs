defmodule Solution do
  # 408
  def solve1(file \\ "./input.txt") do
    file
    |> stream_numbers()
    |> Enum.sum()
  end

  # 55250
  def solve2(file \\ "./input.txt") do
    file
    |> stream_numbers()
    |> Stream.cycle()
    |> Enum.reduce_while(
      {0, MapSet.new()},
      fn
        cur, {acc, map} ->
          new_acc = acc + cur

          if map |> MapSet.member?(new_acc) do
            {:halt, new_acc}
          else
            {:cont, {new_acc, map |> MapSet.put(new_acc)}}
          end
      end
    )
  end

  defp stream_numbers(file) do
    file
    |> File.stream!([:trim_bom])
    |> Stream.map(fn str -> str |> String.trim_trailing("\n") |> String.to_integer() end)
  end
end
