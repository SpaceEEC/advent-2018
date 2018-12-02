defmodule Solution do
  # 6175
  def solve1(file \\ "input.txt") do
    file
    |> File.stream!()
    |> Stream.map(&String.trim_trailing(&1, "\n"))
    |> Enum.flat_map(&count/1)
    |> Enum.reduce([0, 0], fn {two1, three1}, [two2, three2] -> [two1 + two2, three1 + three2] end)
    |> Enum.reduce(&Kernel.*/2)
  end

  defp count(str) do
    do_count(%{}, str)
  end

  defp do_count(map, "") do
    map
    |> Map.values()
    |> Enum.reduce(
      {0, 0},
      fn
        2, {_, three} ->
          {1, three}

        3, {two, _} ->
          {two, 1}

        _, acc ->
          acc
      end
    )
    |> case do
      {0, 0} ->
        []

      other ->
        [other]
    end
  end

  defp do_count(map, <<c::utf8>> <> rest) do
    map
    |> Map.update(c, 1, &(&1 + 1))
    |> do_count(rest)
  end

  def solve2(file \\ "input.txt") do
    file
    |> File.stream!()
    |> Enum.map(&String.trim_trailing(&1, "\n"))
    |> do_solve2()
  end

  defp do_solve2([id1 | rest]) do
    id1 = String.codepoints(id1)

    rest
    |> Enum.find(&do_find(&1, id1))
    |> case do
      nil ->
        do_solve2(rest)

      id2 ->
        id2
        |> String.codepoints()
        |> Enum.zip(id1)
        |> Enum.filter(fn
          {c, c} -> true
          {_, _} -> false
        end)
        |> Enum.map(&elem(&1, 0))
        |> Enum.join()
    end
  end

  defp do_find(id2, id1) do
    id2
    |> String.codepoints()
    |> Enum.zip(id1)
    |> Enum.reduce_while(
      0,
      fn
        {c, c}, 0 ->
          {:cont, 0}

        {_, _}, 0 ->
          {:cont, 1}

        {c, c}, 1 ->
          {:cont, 1}

        {_, _}, _ ->
          {:halt, 2}
      end
    )
    |> Kernel.==(1)
  end
end
