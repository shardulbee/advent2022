let lines_from_file ic =
  let rec lines_from_file_aux ic acc =
    match input_line ic with
    | exception End_of_file -> List.rev acc
    | line -> lines_from_file_aux ic (line :: acc)
  in
  lines_from_file_aux ic []
