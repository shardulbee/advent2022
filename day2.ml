type choice = Rock | Paper | Scissors
type game = { opponent: choice ; mine: choice }
type result = Win | Loss | Draw
type game_result = { opponent: choice; result: result }

let value choice = match choice with
  | Rock -> 1
  | Paper -> 2
  | Scissors -> 3

let result_of (game: game) = match (game.opponent, game.mine) with
  | (Rock, Rock) -> Draw
  | (Paper, Paper) -> Draw
  | (Scissors, Scissors) -> Draw
  | (Scissors, Paper) -> Loss
  | (Scissors, Rock) -> Win
  | (Rock, Paper) -> Win
  | (Rock, Scissors) -> Loss
  | (Paper, Rock) -> Loss
  | (Paper, Scissors) -> Win

let score game = match (result_of game) with
  | Win -> 6 + (value game.mine)
  | Draw -> 3 + (value game.mine)
  | Loss -> 0 + (value game.mine)

let lines_from_file ic =
  let rec lines_from_file_aux ic acc = match (input_line ic) with
    | exception End_of_file  -> List.rev acc
    | line -> lines_from_file_aux ic (line :: acc) in
  lines_from_file_aux ic []

let game_for_result (game : game_result) =
  let my_choice = match (game.opponent, game.result) with
    | (Rock, Win) -> Paper
    | (Rock, Loss) -> Scissors
    | (Paper, Win) -> Scissors
    | (Paper, Loss) -> Rock
    | (Scissors, Win) -> Rock
    | (Scissors, Loss) -> Paper
    | (_, Draw) -> game.opponent in
  { mine = my_choice ; opponent = game.opponent }

exception Invalid_input;;

let parse_one line =
  let of_mine mine = match mine with
      | "X" -> Rock
      | "Y" -> Paper
      | "Z" -> Scissors
      | _ -> failwith "Invalid Input" in

    let of_opponent mine = match mine with
        | "A" -> Rock
        | "B" -> Paper
        | "C" -> Scissors
        | _ -> failwith "Invalid Input" in
      let split = Array.of_list (Str.split (Str.regexp " ") line) in
        { opponent = of_opponent split.(0); mine = of_mine split.(1) }

let parse_two line =
  let of_mine mine = match mine with
      | "X" -> Loss
      | "Y" -> Draw
      | "Z" -> Win
      | _ -> failwith "Invalid Input" in

    let of_opponent mine = match mine with
        | "A" -> Rock
        | "B" -> Paper
        | "C" -> Scissors
        | _ -> failwith "Invalid Input" in
      let split = Array.of_list (Str.split (Str.regexp " ") line) in
        {opponent = of_opponent split.(0); result = of_mine split.(1)}


let rec parse_lines parse_func lines = match lines with
  | [] -> []
  | (head :: tail) -> (parse_func head)::(parse_lines parse_func tail)

let day_to_file day = "./data/day" ^ string_of_int day ^ ".data"

let part_one =
  let ic = open_in (day_to_file 2) in
    let games = parse_lines parse_one (lines_from_file ic) in
      let scores = List.map score games in
        List.fold_left (+) 0 scores

let part_one_test =
  let games = parse_lines parse_one (["A Y"; "B X"; "C Z"]) in
    let scores = List.map score games in
      List.fold_left (+) 0 scores

let part_two_test =
  let games = parse_lines parse_two (["A Y"; "B X"; "C Z"]) in
    let scores = List.map score (List.map (game_for_result) games) in
    List.fold_left (+) 0 scores

let part_two =
  let ic = open_in (day_to_file 2) in
    let games = parse_lines parse_two (lines_from_file ic) in
    let scores = List.map score (List.map (game_for_result) games) in
    List.fold_left (+) 0 scores

let () =
  print_endline ("Part 1 - test: " ^ string_of_int part_one_test);;
  print_endline ("Part 1: " ^ string_of_int part_one);;
  print_endline ("Part 2 - test: " ^ string_of_int part_two_test);;
  print_endline ("Part 2: " ^ string_of_int part_two);;
