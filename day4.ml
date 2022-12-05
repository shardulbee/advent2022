type section_assignment = Assignment of int * int
type assignment_pair = section_assignment * section_assignment

let assignment_contains assignment pt =
  match assignment with
  | Assignment (l, r) -> (
      match (compare pt l, compare pt r) with
      | -1, _ -> false
      | _, 1 -> false
      | _ -> true)

let fully_contains (a1, a2) =
  match a1 with
  | Assignment (left_start, left_end) ->
      assignment_contains a2 left_start && assignment_contains a2 left_end

let overlaps ((a1, a2) : assignment_pair) =
  match a1 with
  | Assignment (left_start, left_end) ->
      assignment_contains a2 left_start || assignment_contains a2 left_end

let pairwise (compare_fn : assignment_pair -> bool) (a1, a2) =
  compare_fn (a1, a2) || compare_fn (a2, a1)

let parse_line line : assignment_pair =
  let create_pair a b c d = (Assignment (a, b), Assignment (c, d)) in
  Scanf.sscanf line "%d-%d,%d-%d" create_pair

let part_one input =
  let assignment_pairs = List.map parse_line input in
  Printf.printf "Part 1: %d\n"
    (List.length (List.filter (pairwise fully_contains) assignment_pairs))

let part_two input =
  let assignment_pairs = List.map parse_line input in
  Printf.printf "Part 2: %d\n"
    (List.length (List.filter (pairwise overlaps) assignment_pairs))

let run (spec : Runspec.spec) =
  let ic = open_in spec.filename in
  let input = Input.lines_of_in_channel ic in
  part_one input;
  part_two input;
  close_in ic
