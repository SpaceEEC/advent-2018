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
      {0, 0, MapSet.new()},
      fn
        cur, {n, acc, map} ->
          new_acc = acc + cur

          if new_acc == 55250 do IO.puts("found #{n}") end

          if map |> MapSet.member?(new_acc) do
            {:halt, {n + 1, new_acc}}
          else
            {:cont, {n + 1, new_acc, map |> MapSet.put(new_acc)}}
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
