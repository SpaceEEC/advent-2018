defmodule Solution do
  # 124850
  def solve1(file \\ "input.txt") do
    file
    |> File.stream!()
    |> Enum.reduce(%{}, &do_reduce_claims/2)
    |> Enum.count(fn
      {_, [_]} -> false
      _ -> true
    end)
  end

  # 1097
  def solve2(file \\ "input.txt") do
    file
    |> File.stream!()
    |> Enum.reduce(%{}, &do_reduce_claims/2)
    |> Enum.split_with(fn
      {_, [_]} -> true
      _ -> false
    end)
    |> Tuple.to_list()
    |> Enum.map(&Enum.flat_map(&1, fn {_, x} -> x end) |> MapSet.new())
    |> Enum.reduce(&MapSet.difference(&2, &1))
    |> MapSet.to_list()
    |> List.first()
  end

  defp do_reduce_claims(str, acc) do
    [id, x, y, size_x, size_y] =
      Regex.run(~r{#(\d+) @ (\d+),(\d+): (\d+)x(\d+)}, str)
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer/1)

    for real_x <- x..(size_x + x - 1),
        real_y <- y..(size_y + y - 1) do
      {real_x, real_y}
    end
    |> Enum.reduce(
      acc,
      &Map.update(&2, &1, [id], fn ids -> [id | ids] end)
    )
  end
end
