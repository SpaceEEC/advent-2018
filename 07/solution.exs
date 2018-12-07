defmodule Solution do
  defp solve(file) do
    steps =
      file
      |> File.stream!()
      |> Enum.map(fn <<"Step ", <<requirement::binary-size(1)>>, " must be finished before step ",
                       <<step::binary-size(1)>>, " can begin.\n">> ->
        {requirement, step}
      end)

    steps_left =
      steps
      |> Enum.flat_map(&Tuple.to_list/1)
      |> Enum.uniq()

    steps =
      steps
      |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
      |> Map.new(fn {k, v} -> {k, Enum.uniq(v)} end)

    {steps, steps_left}
  end

  defp get_available_steps(steps, steps_left) do
    requirement_set =
      steps
      |> Map.keys()

    steps_left
    |> Kernel.--(requirement_set)
    |> Enum.sort()
  end

  def solve1(file \\ "input.txt") do
    {steps, steps_left} = solve(file)

    do_solve1(steps, steps_left)
  end

  defp do_solve1(steps, steps_left, acc \\ [])

  defp do_solve1(_steps, [], acc) do
    acc |> Enum.reverse() |> Enum.join()
  end

  defp do_solve1(steps, steps_left, acc) do
    step =
      steps
      |> get_available_steps(steps_left)
      |> List.first()

    steps
    |> Enum.filter(fn
      {_k, [^step]} -> false
      _ -> true
    end)
    |> Map.new(fn {k, v} -> {k, v -- [step]} end)
    |> do_solve1(steps_left -- [step], [step | acc])
  end

  def solve2(file \\ "input.txt") do
    {steps, steps_left} = solve(file)

    do_solve2(steps, steps_left)
  end

  defp do_solve2(steps, steps_left, acc \\ {[], 0, []})

  # done
  defp do_solve2(_steps, [], {acc, minutes, jobs}) do
    jobs
    |> Enum.reduce({acc, minutes, 0}, fn {step, time}, {acc, minutes, already} ->
      {[step | acc], time + minutes - already, already + minutes}
    end)
    |> elem(1)
  end

  # finish one job when all workers are busy
  defp do_solve2(steps, steps_left, {_, _, [_, _, _, _, _]} = acc) do
    finish_job(steps, steps_left, acc)
  end

  # start available jobs
  defp do_solve2(steps, steps_left, {acc, minutes, workers}) do
    steps
    |> get_available_steps(steps_left)
    |> Enum.take(5 - length(workers))
    |> case do
      [] ->
        finish_job(steps, steps_left, {acc, minutes, workers})

      available_steps ->
        workers =
          available_steps
          |> Enum.map(fn <<code::utf8>> = step ->
            {step, code - ?A + 61}
          end)
          |> Enum.concat(workers)
          |> Enum.sort_by(&elem(&1, 1))

        do_solve2(steps, steps_left -- available_steps, {acc, minutes, workers})
    end
  end

  defp finish_job(steps, steps_left, {acc, minutes, [{step, time} | rest]}) do
    rest =
      rest
      |> Enum.map(fn {step2, time2} -> {step2, time2 - time} end)

    steps
    |> Enum.filter(fn
      {_k, [^step]} -> false
      _ -> true
    end)
    |> Map.new(fn {k, v} -> {k, v -- [step]} end)
    |> do_solve2(steps_left, {[step | acc], minutes + time, rest})
  end
end
