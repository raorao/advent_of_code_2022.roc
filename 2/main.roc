app "day 2"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [pf.Stdout, pf.Path, pf.File, pf.Task]
    provides [main] to pf

translateStrategy = \encrypted ->
    when encrypted is
        EncryptedGame opp X -> Game opp Rock
        EncryptedGame opp Y -> Game opp Paper
        EncryptedGame opp Z -> Game opp Scissors

matchStrategy = \encrypted ->
    when encrypted is
        EncryptedGame Rock X -> Game Rock Scissors
        EncryptedGame Rock Y -> Game Rock Rock
        EncryptedGame Rock Z -> Game Rock Paper
        EncryptedGame Paper X -> Game Paper Rock
        EncryptedGame Paper Y -> Game Paper Paper
        EncryptedGame Paper Z -> Game Paper Scissors
        EncryptedGame Scissors X -> Game Scissors Paper
        EncryptedGame Scissors Y -> Game Scissors Scissors
        EncryptedGame Scissors Z -> Game Scissors Rock

scoreGame = \game ->
    throwBonus = when game is
        Game _ Rock -> 1
        Game _ Paper -> 2
        Game _ Scissors -> 3

    score = when game is
        Game Rock Paper | Game Paper Scissors | Game Scissors Rock -> 6
        Game Rock Rock | Game Paper Paper | Game Scissors Scissors -> 3
        Game Rock Scissors | Game Paper Rock | Game Scissors Paper -> 0

    score + throwBonus

scoreInput = \encryptedGames, decryptStrategy ->
    encryptedGames
    |> List.map decryptStrategy
    |> List.map scoreGame
    |> List.sum

parseRow = \rowStr ->
    when Str.split rowStr " " is
        [oppStr, ownStr] ->
            opp = when oppStr is
                "A" -> Rock
                "B" -> Paper
                "C" -> Scissors
                _ -> crash "unknown opponent throw \(oppStr)"
            own = when ownStr is
                "X" -> X
                "Y" -> Y
                "Z" -> Z
                _ -> crash "unknown own throw \(ownStr)"

            EncryptedGame opp own

        _ -> crash "could not parse \(rowStr)"

main =
    task =
        input <- Path.fromStr "input.txt" |> File.readUtf8 |> Task.await

        parsedInput =
            input
            |> Str.split "\n"
            |> List.map parseRow

        part1 = scoreInput parsedInput translateStrategy |> Num.toStr
        part2 = scoreInput parsedInput matchStrategy |> Num.toStr

        Stdout.write "part 1: \(part1) part 2: \(part2)"

    Task.onFail task \_ -> crash "Failed to read and parse input"

## Tests
expect scoreGame (Game Rock Paper) == 8

sampleInput = [
    EncryptedGame Rock Y,
    EncryptedGame Paper X,
    EncryptedGame Scissors Z,
]

expect scoreInput sampleInput translateStrategy == 15
expect scoreInput sampleInput matchStrategy == 12
