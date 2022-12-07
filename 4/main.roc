app "day 4"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [pf.Stdout, pf.Path, pf.File, pf.Task]
    provides [main] to pf

parseRow = \row ->
    parsePairStr = \pairStr ->
        arr =
            pairStr
            |> Str.split "-"
            |> List.map Str.toNat
            |> List.map (\r -> Result.withDefault r 0)

        when arr is
            [fst, scd] ->
                { start: fst, end: scd }

            _ ->
                crash "could not parse \(pairStr)"

    row
    |> Str.split ","
    |> List.map parsePairStr

fullyContains = \pair ->
    when pair is
        [fst, scd] ->
            if fst.start > scd.start then
                fst.end <= scd.end
            else if fst.start < scd.start then
                fst.end >= scd.end
            else
                Bool.true

        _ ->
            crash "pair had incorrect number of elements"

partiallyContains = \pair ->
    when pair is
        [fst, scd] ->
            if fst.start > scd.start then
                fst.start <= scd.end
            else if fst.start < scd.start then
                fst.end >= scd.start
            else
                Bool.true

        _ ->
            crash "pair had incorrect number of elements"

pairsFullyContain = \rows ->
    rows
    |> List.map parseRow
    |> List.keepIf fullyContains
    |> List.len

pairsPartiallyContain = \rows ->
    rows
    |> List.map parseRow
    |> List.keepIf partiallyContains
    |> List.len

main =
    task =
        input <- Path.fromStr "input.txt" |> File.readUtf8 |> Task.await

        parsedInput =
            input
            |> Str.split "\n"

        part1 = pairsFullyContain parsedInput |> Num.toStr
        part2 = pairsPartiallyContain parsedInput |> Num.toStr

        Stdout.write "part 1: \(part1) part 2: \(part2)"

    Task.onFail task \_ -> crash "Failed to read and parse input"

## Tests
sampleInput = [
    "2-4,6-8",
    "2-3,4-5",
    "5-7,7-9",
    "2-8,3-7",
    "6-6,4-6",
    "2-6,4-8",
]

expect pairsFullyContain ["2-4,6-8"] == 0
expect pairsFullyContain ["2-3,4-5"] == 0
expect pairsFullyContain ["5-7,7-9"] == 0
expect pairsFullyContain ["2-8,3-7"] == 1
expect pairsFullyContain ["6-6,4-6"] == 1
expect pairsFullyContain ["2-6,4-8"] == 0

expect pairsFullyContain ["1-8,1-7"] == 1
expect pairsFullyContain ["2-8,3-8"] == 1

expect pairsFullyContain sampleInput == 2

expect pairsPartiallyContain ["2-4,6-8"] == 0
expect pairsPartiallyContain ["2-3,4-5"] == 0
expect pairsPartiallyContain ["5-7,7-9"] == 1
expect pairsPartiallyContain ["2-8,3-7"] == 1
expect pairsPartiallyContain ["6-7,4-6"] == 1
expect pairsPartiallyContain ["2-6,4-8"] == 1

expect pairsFullyContain ["1-8,1-7"] == 1
expect pairsFullyContain ["3-8,2-8"] == 1

expect pairsPartiallyContain sampleInput == 4
