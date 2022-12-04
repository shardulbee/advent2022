open Input
open Printf

let group_calories lines =
  let rec group_calories_aux lines acc current_group =
    match lines with
    | [] -> List.rev acc
    | current :: rest -> (
        match current with
        | "" -> group_calories_aux rest (List.rev current_group :: acc) []
        | num -> group_calories_aux rest acc (int_of_string num :: current_group)
        )
  in
  group_calories_aux lines [] []

let rec sum_groups groups =
  match groups with
  | [] -> []
  | group :: rest ->
      let summed_group = List.fold_left ( + ) 0 group in
      List.cons summed_group (sum_groups rest)

let group_sum_max groups =
  let summed_groups = sum_groups groups in
  let rec list_max l cur_max =
    match l with
    | [] -> cur_max
    | elem :: rest -> list_max rest (max cur_max elem)
  in
  list_max summed_groups (-1)

let part_one ic =
  let groups = group_calories (Input.lines_of_in_channel ic) in
  print_endline ("Part 1: " ^ string_of_int (group_sum_max groups))

let part_two ic =
  let groups = group_calories (Input.lines_of_in_channel ic) in
  let summed_groups = sum_groups groups in

  let first_three =
    Array.sub (Array.of_list (List.rev (List.sort compare summed_groups))) 0 3
  in
  let result = Array.fold_left ( + ) 0 first_three in
  print_endline ("Part 2: " ^ string_of_int result);
  close_in ic

let run (spec : Runspec.spec) =
  let ic = open_in spec.filename in
  part_one ic;
  seek_in ic 0;
  part_two ic
