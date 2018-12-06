defmodule Solution do
  def solve1(file \\ "test.txt") do
    coordinates =
      file
      |> File.stream!()
      |> Enum.map(fn line ->
        ~r{(\d+), (\d+)}
        |> Regex.run(line)
        |> Enum.drop(1)
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)

    extremes = get_extreme_coordinates(coordinates)

    tmp = count_distances(coordinates, 0..extremes.max_y, 0..extremes.max_x)
    tmp2 = count_distances(coordinates, -1..(extremes.max_y + 1), -1..(extremes.max_x + 1))

    Map.merge(
      tmp,
      tmp2,
      fn
        _, x, x -> x
        _, _x, _y -> nil
      end
    )
    |> Map.values()
    |> Enum.filter(& &1)
    |> Enum.max()
  end

  defp count_distances(coordinates, max_y, max_x) do
    for y <- max_y,
        x <- max_x do
      {x, y}
    end
    |> Task.async_stream(
      fn {x1, y1} ->
        for {x2, y2} = pair <- coordinates do
          {pair, abs(x1 - x2) + abs(y1 - y2)}
        end
        |> Enum.sort_by(&elem(&1, 1))
        |> case do
          [{_pair, dist}, {_pair2, dist} | _] ->
            nil

          [{pair, _dist} | _rest] ->
            # {x1, y1}
            pair
        end
      end,
      ordered: false
    )
    |> Enum.group_by(&elem(&1, 1))
    |> Map.delete(nil)
    |> Map.new(fn {k, v} -> {k, length(v)} end)
  end

  defp get_extreme_coordinates(result \\ %{}, list)
  defp get_extreme_coordinates(result, []), do: result

  defp get_extreme_coordinates(result, [{x, y} | rest]) do
    result
    |> Map.merge(
      %{
        min_x: x,
        min_y: y
      },
      fn _, v1, v2 -> min(v1, v2) end
    )
    |> Map.merge(
      %{
        max_x: x,
        max_y: y
      },
      fn _, v1, v2 -> max(v1, v2) end
    )
    |> get_extreme_coordinates(rest)
  end

  # defp get_extremes(extremes, list, acc \\ [])
  # defp get_extremes(_extremes, [], acc), do: acc

  # defp get_extremes(
  #        %{max_x: x2, max_y: y2, min_x: x3, min_y: y3} = extremes,
  #        [{x1, y1} = coordinates | rest],
  #        acc
  #      )
  #      when x1 in [x2, x3]
  #      when y1 in [y2, y3] do
  #   get_extremes(extremes, rest, [coordinates | acc])
  # end

  # defp get_extremes(extremes, [_coordinates | rest], acc) do
  #   get_extremes(extremes, rest, acc)
  # end
end
