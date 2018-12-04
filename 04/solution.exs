defmodule Solution do
  defp solve(file) do
    file
    |> File.stream!()
    |> Enum.map(&map_events/1)
    |> Enum.sort(fn {date1, _}, {date2, _} -> NaiveDateTime.compare(date1, date2) == :lt end)
    |> reduce_events()
  end

  # 101262
  def solve1(file \\ "input.txt") do
    file
    |> solve()
    |> Enum.max_by(fn {_guard, {minutes, _map}} -> minutes end)
    |> case do
      {guard, {_minutes, map}} ->
        highest =
          map
          |> Enum.max_by(fn {_minute, count} -> count end)
          |> elem(0)

        guard * highest
    end
  end

  defp map_events(event) do
    Regex.run(
      ~r/\[(\d+)-(\d+)-(\d+) (\d+):(\d+)\] (?:Guard #(\d+)|falls (asleep)|wakes (up))/,
      event
    )
    |> Enum.drop(1)
    |> get_date_time()
    |> case do
      {date_time, [guard]} ->
        {date_time, String.to_integer(guard)}

      {date_time, ["", asleep]} ->
        {date_time, asleep}

      {date_time, ["", "", up]} ->
        {date_time, up}
    end
  end

  defp get_date_time([year, month, day, hour, minute | rest]) do
    {:ok, date_time} =
      NaiveDateTime.new(
        String.to_integer(year),
        String.to_integer(month),
        String.to_integer(day),
        String.to_integer(hour),
        String.to_integer(minute),
        0
      )

    {date_time, rest}
  end

  defp reduce_events(acc \\ %{}, list)

  defp reduce_events(acc, []), do: acc

  defp reduce_events(acc, [{_date, guard} | rest]) when is_integer(guard) do
    {state, rest} =
      acc
      |> Map.get(guard, {0, %{}})
      |> get_span(rest)

    acc
    |> Map.put(guard, state)
    |> reduce_events(rest)
  end

  defp get_span({minutes, map}, [{start, "asleep"}, {stop, "up"} | rest]) do
    minutes =
      NaiveDateTime.diff(stop, start)
      |> div(60)
      |> Kernel.+(minutes)

    map =
      start.minute..(stop.minute - 1)
      |> Enum.reduce(map, &Map.update(&2, &1, 1, fn m -> m + 1 end))

    {minutes, map}
    |> get_span(rest)
  end

  defp get_span(state, rest), do: {state, rest}

  # 71976
  def solve2(file \\ "input.txt") do
    file
    |> solve()
    |> Enum.map(fn
      {guard, {_minutes, map}} ->
        {minute, count} = Enum.max_by(map, fn {_minute, count} -> count end, fn -> {0, 0} end)

        {guard, minute, count}
    end)
    |> Enum.max_by(fn {_guard, _minute, count} -> count end)
    |> case do
      {guard, minute, _count} ->
        guard * minute
    end
  end
end
