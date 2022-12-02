let day_to_file day = "./data/day" ^ string_of_int day ^ ".data"

let lines_from_file ic =
  let rec lines_from_file_aux ic acc = match (input_line ic) with
    | exception End_of_file  -> List.rev acc
    | line -> lines_from_file_aux ic (line :: acc) in
  lines_from_file_aux ic []

let lines_for_day day = lines_from_file (open_in (day_to_file day))

let group_calories lines =
  let rec group_calories_aux lines acc current_group = match lines with
    | [] -> List.rev acc
    | (current :: rest) -> match current with
      | "" -> group_calories_aux rest ((List.rev current_group) :: acc) []
      | num -> group_calories_aux rest acc ((int_of_string num) :: current_group) in
  group_calories_aux lines [] []

let rec sum_groups groups = match groups with
  | [] -> []
  | (group :: rest) -> (List.fold_left (+) 0 group)::(sum_groups rest)

let group_sum_max groups =
  let summed_groups = sum_groups groups in
    let rec list_max l cur_max = match l with
      | [] -> cur_max
      | (elem :: rest) -> list_max rest (max cur_max elem) in
      list_max summed_groups (-1)

let part_one =
  let ic = open_in (day_to_file 1) in
    let groups = group_calories (lines_from_file ic) in
      print_endline("Part 1: " ^ string_of_int (group_sum_max groups))

let part_two =
  let ic = open_in (day_to_file 1) in
    let groups = group_calories (lines_from_file ic) in
      let summed_groups = sum_groups groups in
        let first_three = Array.sub (Array.of_list (List.rev (List.sort compare summed_groups))) 0 3 in
          let result = Array.fold_left (+) 0 first_three in
            print_endline("Part 1: " ^ string_of_int (result));
  close_in ic;

