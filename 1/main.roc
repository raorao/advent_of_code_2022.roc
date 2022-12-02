app "day 1"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [pf.Stdout, pf.Path, pf.File, pf.Task]
    provides [main] to pf

elfWithMostCalories = \calories ->
    calories
        |> List.append Empty
        |> List.walk {current: 0, max: 0} \state, elem ->
            when elem is
                Food calorieCount ->
                    { state & current: (state.current + calorieCount) }
                Empty ->
                    {
                        current: 0,
                        max:
                            if state.current > state.max then
                                state.current
                            else
                                state.max
                    }

        |> .max

elvesWithMostCalories = \calories ->
    calories
        |> List.append Empty
        |> List.walk {current: 0, maxThree: [0,0,0]} \state, elem ->
            when elem is
                Food calorieCount ->
                    { state & current: (state.current + calorieCount) }
                Empty ->
                    {
                        current: 0,
                        maxThree:
                            state.maxThree
                                |> List.append state.current
                                |> List.sortDesc
                                |> List.takeFirst 3
                    }

        |> .maxThree
        |> List.sum

parseRow = \row ->
    when row is
        "" -> Empty
        str ->
            when (Str.toNat str) is
                Ok int -> Food int
                Err _ -> crash "could not parse \(str)"

main =
    task =
        input <- Path.fromStr "input.txt" |> File.readUtf8 |> Task.await

        parsedInput = input
            |> Str.split "\n"
            |> List.map parseRow

        part1 = parsedInput |> elfWithMostCalories |> Num.toStr
        part2 = parsedInput |> elvesWithMostCalories |> Num.toStr

        Stdout.write "part 1: \(part1) part 2: \(part2)"

    Task.onFail task \_ -> crash "Failed to read and parse input"

# TESTS

exampleInput = [
    Food 1000,
    Food 2000,
    Food 3000,
    Empty,
    Food 4000,
    Empty,
    Food 5000,
    Food 6000,
    Empty,
    Food 7000,
    Food 8000,
    Food 9000,
    Empty,
    Food 10000
]

expect elfWithMostCalories exampleInput == 24000
expect elvesWithMostCalories exampleInput == 45000

lastElfInput = [
    Food 1000,
    Food 2000,
    Food 3000,
    Empty,
    Food 4000,
    Empty,
    Food 5000,
    Food 6000,
    Empty,
    Food 7000,
    Food 8000
]

expect elfWithMostCalories lastElfInput == 15000

firstElfInput = [
    Food 10000,
    Food 2000,
    Food 3000,
    Empty,
    Food 4000,
    Empty,
    Food 5000,
    Food 6000,
    Empty,
    Food 7000
]

expect elfWithMostCalories firstElfInput == 15000

emptyInput = [ ]

expect elfWithMostCalories emptyInput == 0