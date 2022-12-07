app "hello"
    packages { pf: "https://github.com/roc-lang/basic-cli/releases/download/0.1.1/zAoiC9xtQPHywYk350_b7ust04BmWLW00sjb9ZPtSQk.tar.br" }
    imports [pf.Stdout]
    provides [main] to pf

animals = { birds: 2, iguanas: 0 }

addAndStringify = \{ birds: num1, iguanas: num2 } ->
    sum = num1 + num2

    when sum is
        0 -> "no"
        1 | 2 | 3 -> "fewer than three"
        num -> Num.toStr num

res = addAndStringify animals

main =
    Stdout.line "There are \(res) animals."

pluralize = \singular, plural, count ->
    countStr = Num.toStr count

    if count < 2 then
        "\(countStr) \(singular)"
    else
        "\(countStr) \(plural)"

expect pluralize "cactus" "cacti" 1 == "1 cactus"

expect pluralize "cactus" "cacti" 2 == "2 cacti"
