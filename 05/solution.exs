defmodule Solution do
  defp read_file(file) do
    file
    |> File.stream!()
    |> Enum.take(1)
    |> List.first()
    |> String.trim_trailing("\n")
  end

  defp collapse_polymer(str1, str2 \\ "", ignore_char \\ nil)

  defp collapse_polymer("", str2, ignore_char), do: str2 |> String.reverse()

  defp collapse_polymer(<<c1::utf8, rest1::binary>>, str2, ignore_char)
       when c1 in [ignore_char, ignore_char + ?A - ?a] do
    collapse_polymer(rest1, str2, ignore_char)
  end

  defp collapse_polymer(<<c1::utf8, rest1::binary>>, <<c2::utf8, rest2::binary>>, ignore_char)
       when (c1 - c2) in [?A - ?a, ?a - ?A] do
    collapse_polymer(rest1, rest2, ignore_char)
  end

  defp collapse_polymer(<<c1::utf8, rest1::binary>>, str2, ignore_char) do
    collapse_polymer(rest1, <<c1::utf8, str2::binary>>, ignore_char)
  end

  # 10978
  def solve1(file \\ "input.txt") do
    file
    |> read_file()
    |> collapse_polymer()
    |> String.length()
  end

  # 4840
  def solve2(file \\ "input.txt") do
    composition = read_file(file)

    for char <- ?a..?z do
      composition
      |> collapse_polymer("", char)
      |> String.length()
    end
    |> Enum.min()
  end
end
