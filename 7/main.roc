app "day 7"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [pf.Stdout, pf.Path, pf.File, pf.Task]
    provides [main] to pf

calculateSize = \fileSystem, pwd ->
    entries = when Dict.get fileSystem pwd is
        Ok x -> x
        Err _ -> crash "could not find pwd"

    entries
    |> List.map \entry ->
        when entry is
            File _name size -> size
            Directory subdir -> calculateSize fileSystem subdir
    |> List.sum

part1Calculator = \fileSystem ->
    fileSystem
    |> Dict.keys
    |> List.map \dir -> calculateSize fileSystem dir
    |> List.keepIf \size -> size <= 100000
    |> List.sum

part2Calculator = \fileSystem, totalSpace, neededUnusedSpace ->
    usedSpace = calculateSize fileSystem ["/"]
    unusedSpace = totalSpace - usedSpace
    diff = neededUnusedSpace - unusedSpace

    fileSystem
    |> Dict.keys
    |> List.map \dir -> calculateSize fileSystem dir
    |> List.sortAsc
    |> List.findFirst (\size -> size >= diff)
    |> Result.withDefault 0

parseFileSystem = \instructions ->
    result =
        instructions
        |> Str.split "$ "
        |> List.dropFirst # deal with garbage before first $
        |> List.walk { pwd: [], fileSystem: Dict.empty } \state, elem ->
            { before: command, others: lsOutput } =
                elem
                |> Str.split "\n"
                |> List.map \line -> Str.split line " "
                |> List.split 1

            when command is
                [["cd", "/"]] ->
                    { state & pwd: ["/"] }

                [["cd", ".."]] ->
                    { state & pwd: List.dropLast state.pwd }

                [["cd", dir]] ->
                    { state & pwd: List.append state.pwd dir }

                [["ls"]] ->
                    entries =
                        lsOutput
                        |> List.dropIf \line -> line == [""] # remove empty lines
                        |> List.map \line ->
                            when line is
                                ["dir", directory] ->
                                    Directory (List.append state.pwd directory)

                                [sizeStr, filename] ->
                                    size = when Str.toNat sizeStr is
                                        Ok val -> val
                                        Err _ -> crash "invalid size \(sizeStr) for file \(filename)"

                                    File filename size

                                _ -> crash "invalid ls output"

                    { state & fileSystem: Dict.insert state.fileSystem state.pwd entries }

                _ -> crash "invalid command"

    result.fileSystem

main =
    task =
        input <- Path.fromStr "input.txt" |> File.readUtf8 |> Task.await

        inputFileSystem = parseFileSystem input

        part1 = part1Calculator inputFileSystem |> Num.toStr
        part2 = part2Calculator inputFileSystem 70000000 30000000 |> Num.toStr

        Stdout.write "part 1: \(part1) part 2: \(part2)"

    Task.onFail task \_ -> crash "Failed to read and parse input"

## Tests
sampleInput =
    """
    $ cd /
    $ ls
    dir a
    14848514 b.txt
    8504156 c.dat
    dir d
    $ cd a
    $ ls
    dir e
    29116 f
    2557 g
    62596 h.lst
    $ cd e
    $ ls
    584 i
    $ cd ..
    $ cd ..
    $ cd d
    $ ls
    4060174 j
    8033020 d.log
    5626152 d.ext
    7214296 k
    """

sampleFileSystem = parseFileSystem sampleInput

raoFs =
    Dict.empty
    |> Dict.insert ["/", "foo", "bar"] []
    |> Dict.insert ["/", "foo"] [File "bar.sh" 584, Directory ["/", "foo", "bar"]]

expect calculateSize raoFs ["/", "foo"] == 584
expect calculateSize sampleFileSystem ["/", "a", "e"] == 584
expect calculateSize sampleFileSystem ["/", "a"] == 94853
expect calculateSize sampleFileSystem ["/", "d"] == 24933642
expect part1Calculator sampleFileSystem == 95437
expect part2Calculator sampleFileSystem 70000000 30000000 == 24933642
