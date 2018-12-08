defmodule Solution do
  def solve(file) do
    {node, "\n"} =
      file
      |> File.stream!()
      |> Enum.take(1)
      |> List.first()
      |> read_node()

    node
  end

  defp read_numbers(str, 0), do: {[], str}

  defp read_numbers(str, count) do
    Enum.reduce(
      1..count,
      {[], str},
      fn _, {numbers, str} ->
        {number, str} = read_number(str)
        {[number | numbers], str}
      end
    )
  end

  defp read_number(str) do
    str
    |> String.trim_leading(" ")
    |> Integer.parse()
  end

  defp read_nodes(str, 0), do: {[], str}

  defp read_nodes(str, count) do
    Enum.reduce(
      1..count,
      {[], str},
      fn _, {nodes, str} ->
        {node, str} = read_node(str)
        {[node | nodes], str}
      end
    )
  end

  defp read_node(str) do
    {node_count, str} = read_number(str)
    {meta_count, str} = read_number(str)

    {nodes, str} = read_nodes(str, node_count)
    {meta, str} = read_numbers(str, meta_count)

    node = %{
      meta: meta |> Enum.reverse(),
      nodes: nodes |> Enum.reverse()
    }

    {node, str}
  end

  # 40309
  def solve1(file \\ "test.txt") do
    node = solve(file)

    do_solve1(node)
  end

  # 28779
  def solve2(file \\ "test.txt") do
    node = solve(file)

    do_solve2(node)
  end

  defp do_solve1(%{meta: meta, nodes: nodes}) do
    nodes
    |> Enum.map(&do_solve1/1)
    |> Enum.sum()
    |> Kernel.+(meta |> Enum.sum())
  end

  defp do_solve2(%{meta: meta, nodes: []}), do: meta |> Enum.sum()

  defp do_solve2(%{meta: indexes, nodes: nodes}) do
    indexes
    |> Enum.map(fn
      0 ->
        0

      index ->
        nodes
        |> Enum.at(index - 1)
        |> case do
          nil ->
            0

          node ->
            do_solve2(node)
        end
    end)
    |> Enum.sum()
  end
end
