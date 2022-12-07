app "day 5"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [pf.Stdout, pf.Path, pf.File, pf.Task]
    provides [main] to pf

stackTops = \crates ->
    crates
        |> List.keepOks List.last
        |> List.walk "" Str.concat

apply9000Instruction = \crates, {count,originIndex,targetIndex} ->
    List.repeat "" count
        |> List.walk crates \memo, _ ->
            origin =
                when List.get memo originIndex is
                    Ok val -> val
                    Err _ -> crash "could not access stack"

            newOrigin = List.dropLast origin
            elem = List.last origin

            target =
                when List.get memo targetIndex is
                    Ok val -> val
                    Err _ -> crash "could not access stack"

            newTarget =
                when elem is
                    Ok val -> List.append target val
                    Err _ -> target

            memo
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

apply9000Instructions = \crates, instructions ->
    instructions
        |> List.map parseInstruction
        |> List.walk crates apply9000Instruction
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

        Stdout.write "part 1: \(part1)"

    Task.onFail task \_ -> crash "Failed to read and parse input"

## Tests

sampleCrates = [
    [ "Z", "N" ],
    [ "M", "C", "D" ],
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



# remote last item in crate, append to target crate
# calculcate last item in each stack, and combine into one string.
