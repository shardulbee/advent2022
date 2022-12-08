let lines_of_in_channel ic =
  let rec lines_from_file_aux ic acc =
    match input_line ic with
    | exception End_of_file -> List.rev acc
    | line -> lines_from_file_aux ic (line :: acc)
  in
  lines_from_file_aux ic []

let chars_of_in_channel ic =
  let rec aux acc =
    match input_char ic with
    | exception End_of_file -> List.rev acc
    | '\n' -> aux acc
    | c -> aux (c :: acc)
  in
  aux []
