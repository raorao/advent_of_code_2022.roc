app "day 6"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [pf.Stdout, pf.Path, pf.File, pf.Task]
    provides [main] to pf

startOfPacket = \str, count ->
    split =
        str
        |> Str.graphemes
        |> List.split count

    result = List.walkUntil split.others { index: count, lastFour: split.before } \state, elem ->
        newState = {
            index: state.index + 1,
            lastFour: (state.lastFour |> List.dropFirst |> List.append elem),
        }

        len =
            newState.lastFour
            |> Set.fromList
            |> Set.len

        if len < count then
            Continue newState
        else
            Break newState

    result.index

main =
    task =
        input <- Path.fromStr "input.txt" |> File.readUtf8 |> Task.await

        part1 = startOfPacket input 4 |> Num.toStr
        part2 = "TBD"

        Stdout.write "part 1: \(part1) part 2: \(part2)"

    Task.onFail task \_ -> crash "Failed to read and parse input"

## Tests
expect startOfPacket "bvwbjplbgvbhsrlpgdmjqwftvncz" 4 == 5
expect startOfPacket "nppdvjthqldpwncqszvftbrmjlhg" 4 == 6
expect startOfPacket "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg" 4 == 10
expect startOfPacket "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw" 4 == 11
