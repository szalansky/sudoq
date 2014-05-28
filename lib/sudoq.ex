defmodule Sudoq do
  @rows 'ABCDEFGHI'
  @cols '123456789'
  @digits '123456789'

  def cross(rows, cols) do
    for r <- rows, c <- cols, do: [r] ++ [c]
  end

  def unit_list do
    (for c <- @cols, do: cross(@rows, [c])) ++
    (for r <- @rows, do: cross([r], @cols)) ++
    (for rs <- ['ABC', 'DEF', 'GHI'], cs <- ['123', '456', '789'], do: cross(rs, cs))
  end

  def units do
    un = unit_list

    for sq <- cross(@rows, @cols) do
      { sq, (for u <- un, sq in u, do: u) |> Enum.reduce([], fn(a, acc) -> acc ++ a end)}
    end |> Enum.into(HashDict.new)
  end

  def peers do
    un = units

    for sq <- cross(@rows, @cols) do
      {sq, un[sq] |> Enum.filter(fn(x) -> x != sq end)}
    end |> Enum.into(HashDict.new)
  end

  def parse_game(game) do
    squares = cross(@rows, @cols)
    empty_grid = (for sq <- squares, do: {sq, @digits}) |> Enum.into(HashDict.new)
    # game_values = game_values(game)
    # assign..
  end

  def game_values(game) do
    if Enum.count(game) != 81 do
      throw "Wrong length of input (81 characters required)."
    end
    values = for digit <- game, digit in @digits or digit in '0.', do: [digit]
    Enum.zip(cross(@rows, @cols), values) |> Enum.into(HashDict.new)
  end

  def search(grid) do

  end

  def assign(grid, sq, digit) do
    # Unlike Mr Norvig, I assign a given digit to a cell and eliminate it from others.
    # This fits immutable data structures world better.
    Dict.put(grid, sq, digit) |> eliminate(sq, digit)
  end

  def eliminate(grid, sq, digit) do
    digits = for d <- grid[sq], do: [d]
    peers_for_sq = peers[sq]
    unless digit in digits do
      grid
    else
      {values, count} = eliminate_from_square(grid[sq], digit)
      if count == 0 do
        false
      else
        if count == 1 do
          eliminated = for s <- peers_for_sq do
            { eliminated_digits, _ } = eliminate_from_square(grid[s], digit)
            { s, eliminated_digits }
          end

          unless Enum.all?(eliminated, fn({v,c}) -> v end) do
            false
          else
            Dict.merge(grid, Enum.into(eliminated, HashDict.new))
          end
        end
      end
    end
  end

  def eliminate_from_square(values, digit) do
    digits = for v <- values, do: [v]
    if digit in digits do
      {digits |> Enum.filter(fn(d) -> d != digit end) |> List.flatten, 1}
    else
      {false,0}
    end
  end
end
