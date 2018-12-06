defmodule Solution do
  defp solve(file) do
    file
    |> File.stream!()
    |> Enum.map(fn line ->
      ~r{(\d+), (\d+)}
      |> Regex.run(line)
      |> Enum.drop(1)
      |> Enum.map(&String.to_integer/1)
      |> List.to_tuple()
    end)
  end

  # 3293
  def solve1(file \\ "test.txt") do
    coordinates = solve(file)

    {max_y, max_x, min_y, min_x} =
      Enum.reduce(coordinates, {nil, nil, nil, nil}, fn
        {x, y}, {nil, nil, nil, nil} ->
          {y, x, y, x}

        {x, y}, {max_y, max_x, min_y, min_x} ->
          {max(y, max_y), max(x, max_x), min(y, min_y), min(x, min_x)}
      end)

    coords =
      for {x_generator, y_generator} <- [
            {[min_x, max_x], min_y..max_y},
            {min_x..max_x, [min_y, max_y]}
          ],
          x <- x_generator,
          y <- y_generator do
        {x, y}
      end

    tmp = count_distances(coordinates, min_y..max_y, min_x..max_x)

    tmp2 =
      tmp
      |> Map.take(coords)
      |> Map.values()
      |> Enum.uniq()

    tmp
    |> Map.values()
    |> Enum.group_by(& &1)
    |> Map.drop(tmp2)
    |> Enum.map(&length(elem(&1, 1)))
    |> Enum.max()
  end

  defp count_distances(coordinates, max_y, max_x) do
    for y <- max_y,
        x <- max_x do
      {x, y}
    end
    |> Task.async_stream(
      fn {x1, y1} = coord ->
        for {x2, y2} = pair <- coordinates do
          {pair, abs(x1 - x2) + abs(y1 - y2)}
        end
        |> Enum.sort_by(&elem(&1, 1))
        |> case do
          [{_pair, dist}, {_pair2, dist} | _] ->
            nil

          [{pair, _dist} | _rest] ->
            {coord, pair}
        end
      end,
      ordered: false
    )
    |> Enum.filter(&elem(&1, 1))
    |> Map.new(&elem(&1, 1))
  end
end
