open Printf
module Chars = Set.Make (Char)

let print_chars chars =
  print_endline (String.concat ", " (List.map (String.make 1) chars))

let set_length set = Chars.fold (fun char acc -> acc + 1) set 0

let all_different original_chars =
  let rec aux chars set =
    match chars with
    | [] -> set_length set = List.length original_chars
    | hd :: tl -> aux tl (Chars.add hd set)
  in
  aux original_chars Chars.empty

let part_one chars =
  let rec part_one_aux (hd :: tl) acc idx =
    match List.length acc = 4 with
    | false -> part_one_aux tl (hd :: acc) (idx + 1)
    | true -> (
        match all_different acc with
        | true ->
            print_chars acc;
            idx
        | false ->
            part_one_aux tl (hd :: List.rev (List.tl (List.rev acc))) (idx + 1))
  in
  part_one_aux chars [] 1

let part_two chars =
  let rec part_two_aux (hd :: tl) acc idx =
    match List.length acc = 14 with
    | false -> part_two_aux tl (hd :: acc) (idx + 1)
    | true -> (
        match all_different acc with
        | true ->
            print_chars acc;
            idx
        | false ->
            part_two_aux tl (hd :: List.rev (List.tl (List.rev acc))) (idx + 1))
  in
  part_two_aux chars [] 1

let run (spec : Runspec.spec) =
  let ic = open_in spec.filename in
  let chars = Input.chars_of_in_channel ic in
  (* printf "The answer to part 1: %d" (part_one chars); *)
  printf "The answer to part 2: %d" (part_two chars);
  close_in ic
