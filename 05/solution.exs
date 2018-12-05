defmodule Solution do
  defp read_file(file) do
    file
    |> File.stream!()
    |> Enum.take(1)
    |> List.first()
    |> String.trim_trailing("\n")
  end

  defp collapse_polymer(str1, str2 \\ "", ignore_chars \\ nil)

  defp collapse_polymer("", str2, _ignore_chars), do: str2 |> String.reverse()

  defp collapse_polymer(<<c1::utf8, rest1::binary>>, str2, {ignore1, ignore2} = ignore_chars)
       when c1 in [ignore1, ignore2] do
    collapse_polymer(rest1, str2, ignore_chars)
  end

  defp collapse_polymer(<<c1::utf8, rest1::binary>>, <<c2::utf8, rest2::binary>>, ignore_chars)
       when (c1 - c2) in [?A - ?a, ?a - ?A] do
    collapse_polymer(rest1, rest2, ignore_chars)
  end

  defp collapse_polymer(<<c1::utf8, rest1::binary>>, str2, ignore_chars) do
    collapse_polymer(rest1, <<c1::utf8, str2::binary>>, ignore_chars)
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

    for chars <- [?a..?z, ?A..?Z] |> Enum.zip() do
      composition
      |> collapse_polymer("", chars)
      |> String.length()
    end
    |> Enum.min()
  end
end
