app "day 5"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [pf.Stdout, pf.Path, pf.File, pf.Task]
    provides [main] to pf

stackTops = \crates ->
    crates
        |> List.keepOks List.last
        |> List.walk "" Str.concat

apply9000Instruction = \crates, {count,originIndex,targetIndex} ->
    origin =
        when List.get crates originIndex is
            Ok val -> val
            Err _ -> crash "could not access stack"

    split = List.split origin ((List.len origin) - count)
    newOrigin = split.before
    elems = split.others |> List.reverse

    target =
        when List.get crates targetIndex is
            Ok val -> val
            Err _ -> crash "could not access stack"


    newTarget = target
        |> List.reserve (count + 1)
        |> List.concat elems

    crates
        |> List.replace originIndex newOrigin
        |> .list
        |> List.replace targetIndex newTarget
        |> .list

apply9001Instruction = \crates, {count,originIndex,targetIndex} ->
    origin =
        when List.get crates originIndex is
            Ok val -> val
            Err _ -> crash "could not access stack"

    split = List.split origin ((List.len origin) - count)
    newOrigin = split.before
    elems = split.others

    target =
        when List.get crates targetIndex is
            Ok val -> val
            Err _ -> crash "could not access stack"


    newTarget = target
        |> List.reserve (count + 1)
        |> List.concat elems

    crates
        |> List.replace originIndex newOrigin
        |> .list
        |> List.replace targetIndex newTarget
        |> .list


parseInstruction = \instructionStr ->
    parseNum = \str ->
        when Str.toNat str is
            Ok num -> num
            Err _ -> crash "could not parse \(str)"

    when Str.split instructionStr " " is
        ["move", count, "from", originIndex, "to", targetIndex] ->
            {
                count: parseNum count,
                originIndex: (parseNum originIndex) - 1,
                targetIndex: (parseNum targetIndex) - 1
            }
        _ -> crash "could not parse \(instructionStr)"

# printCrates = \crates ->
#     crates
#         |> List.map (\c -> List.walk c "" Str.concat)
#         |> List.intersperse "|"
#         |> List.walk "" Str.concat

apply9000Instructions = \crates, instructions ->
    instructions
        |> List.map parseInstruction
        |> List.walk crates apply9000Instruction
        |> stackTops

apply9001Instructions = \crates, instructions ->
    instructions
        |> List.map parseInstruction
        |> List.walk crates apply9001Instruction
        |> stackTops

main =
    task =
        input <- Path.fromStr "input.txt" |> File.readUtf8 |> Task.await

        crates = [
            ["N", "B", "D", "T", "V", "G", "Z", "J"],
            ["S", "R", "M", "D", "W", "P", "F"],
            ["V", "C", "R", "S", "Z"],
            ["R", "T", "J", "Z", "P", "H", "G"],
            ["T", "C", "J", "N", "D", "Z", "Q", "F"],
            ["N", "V", "P", "W", "G", "S", "F", "M"],
            ["G", "C", "V", "B", "P", "Q"],
            ["Z", "B", "P", "N"],
            ["W", "P", "J"]
        ]

        parsedInstructions = input
            |> Str.split "\n"

        part1 = apply9000Instructions crates parsedInstructions
        part2 = apply9001Instructions crates parsedInstructions

        Stdout.write "part 1: \(part1) part 2: \(part2)"

    Task.onFail task \_ -> crash "Failed to read and parse input"

## Tests

sampleCrates = [
    [ "Z", "N" ],
    [ "M", "C", "D"],
    [ "P" ]
]

sampleInstructions = [
    "move 1 from 2 to 1",
    "move 3 from 1 to 3",
    "move 2 from 2 to 1",
    "move 1 from 1 to 2"
]

expect stackTops sampleCrates == "NDP"
expect apply9000Instructions sampleCrates sampleInstructions == "CMZ"
expect apply9001Instructions sampleCrates sampleInstructions == "MCD"

