app "day 3"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [pf.Stdout, pf.Path, pf.File, pf.Task]
    provides [main] to pf

matchingItem = \rucksack ->
    chars = rucksack
        |> Str.graphemes

    {before, others} = chars
        |> List.split ((List.len chars) // 2)

    result = before
        |> Set.fromList
        |> Set.intersection (Set.fromList others)
        |> Set.toList
        |> List.first

    when result is
        Ok char -> char
        Err ListWasEmpty -> crash "error: list was empty"

matchingBadge = \rucksacks ->
    result = rucksacks
        |> List.map Str.graphemes
        |> List.map Set.fromList
        |> List.walk Set.empty \state, elem ->
            if Set.len state > 0 then
               Set.intersection state elem
            else
                elem
        |> Set.toList
        |> List.first

    when result is
        Ok char -> char
        Err ListWasEmpty -> crash "error: list was empty"

itemPriority = \char ->
    codeUnit = char
        |> Str.toScalars
        |> List.first
        |> Result.withDefault 0

    # UTF codes: a-z 97-122, A-Z 65-90
    if codeUnit > 96 then
        codeUnit - 96
    else if codeUnit > 64 then
        codeUnit - 38
    else
        crash "unexpected codeUnit from str \(char)"

rucksackPriorities = \rucksacks ->
    rucksacks
        |> List.map matchingItem
        |> List.map itemPriority
        |> List.sum

groupPriorities = \rucksacks ->
    {groups, current} = List.walk rucksacks {groups: [ ], current: [ ]} \state, elem ->
        if List.len state.current < 3 then
            { state & current: (List.append state.current elem) }
        else
            {
                groups: (List.append state.groups state.current),
                current: [elem]
            }

    groups
        |> List.append current
        |> List.map matchingBadge
        |> List.map itemPriority
        |> List.sum
main =
    task =
        input <- Path.fromStr "input.txt" |> File.readUtf8 |> Task.await

        parsedInput = input
            |> Str.split "\n"

        part1 = rucksackPriorities parsedInput |> Num.toStr

        part2 = groupPriorities parsedInput |> Num.toStr

        Stdout.write "part 1: \(part1) part 2: \(part2)"

    Task.onFail task \_ -> crash "Failed to read and parse input"

## Tests

sampleInput = [
    "vJrwpWtwJgWrhcsFMMfFFhFp",
    "jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL",
    "PmmdzqPrVvPwwTWBwg",
    "wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn",
    "ttgJtRGJQctTZtZT",
    "CrZsJsPPZsGzwwsLwLmpwMDw"
]

expect matchingItem "vJrwpWtwJgWrhcsFMMfFFhFp" == "p"
expect matchingItem "jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL" == "L"
expect matchingItem "PmmdzqPrVvPwwTWBwg" == "P"
expect matchingItem "wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn" == "v"

expect itemPriority "p" == 16
expect itemPriority "L" == 38

expect rucksackPriorities sampleInput == 157

expect matchingBadge (List.takeFirst sampleInput 3) == "r"
expect matchingBadge (List.takeLast sampleInput 3) == "Z"
expect groupPriorities sampleInput == 70