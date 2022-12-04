open Printf

type rucksack = { left : char list; right : char list }

module Chars = Set.Make (Char)

let item_in_both rucksack =
  let intersection =
    Chars.inter (Chars.of_list rucksack.left) (Chars.of_list rucksack.right)
  in
  Chars.min_elt intersection

let print_item char = printf "The item is: %c\n" char

let is_lower char =
  let compare = Char.compare char 'a' in
  compare >= 0 && compare < 26

let is_upper char =
  let compare = Char.compare char 'A' in
  compare >= 0 && compare < 26

let priority char =
  match (is_lower char, is_upper char) with
  | true, true -> failwith "Impossible"
  | false, false -> failwith "Impossible"
  | true, false -> Char.compare char 'a' + 1
  | false, true -> Char.compare char 'A' + 27

let halves list =
  let rec take list n acc =
    match (n, list) with
    | 0, _ -> acc
    | _, [] -> acc
    | _, head :: rest -> take rest (n - 1) (head :: acc)
  in
  let to_take = List.length list / 2 in
  {
    left = List.rev (take list to_take []);
    right = take (List.rev list) to_take [];
  }

let chars_of_line line = List.init (String.length line) (String.get line)
let rucksack_of_line line = halves (chars_of_line line)
let rucksacks_of_lines lines = List.map rucksack_of_line lines

let part_one input =
  let rucksacks = rucksacks_of_lines input in
  let answer =
    List.fold_left ( + ) 0 (List.map priority (List.map item_in_both rucksacks))
  in
  printf "Part 1 - %d\n" answer

let each_slice list n =
  let maxlength = n - 1 in
  let rec each_slice_aux list acc current curlength =
    match list with
    | [] -> acc
    | hd :: tl -> (
        match curlength >= maxlength with
        | true -> each_slice_aux tl ((hd :: current) :: acc) [] 0
        | false -> each_slice_aux tl acc (hd :: current) (curlength + 1))
  in
  each_slice_aux list [] [] 0

let badge group =
  let to_chars rucksack = List.append rucksack.left rucksack.right in
  let sets = List.map Chars.of_list (List.map to_chars group) in
  Chars.min_elt (List.fold_left Chars.inter (List.hd sets) sets)

let part_two input =
  let rucksacks = rucksacks_of_lines input in
  let grouped = each_slice rucksacks 3 in
  let badges = List.map badge grouped in
  let result = List.fold_left ( + ) 0 (List.map priority badges) in
  printf "Part 2 - %d\n" result

let run (spec : Runspec.spec) =
  let ic = open_in spec.filename in
  let input = Input.lines_from_file ic in
  part_one input;
  part_two input;
  close_in ic
