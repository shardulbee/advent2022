open Printf
open Str

type fs_node = File of int | Dir of (string * fs_node list)
type line_type = File_line | Dir_line | Cd_Down | Cd_Up | Ls

let rec size node =
  match node with
  | File sz -> sz
  | Dir (_, children) -> List.fold_left ( + ) 0 (List.map size children)

let rec sum_children_leq sz root =
  match root with
  | File _ -> 0
  | Dir (_, children) ->
      let root_size = size root in
      let children_sizes =
        List.fold_left ( + ) 0 (List.map (sum_children_leq sz) children)
      in
      if root_size <= sz then root_size + children_sizes else children_sizes

let dirname dir = Scanf.sscanf dir "dir %s" (fun s -> s)
let file_of_string str = Scanf.sscanf str "%d %s" (fun sz _ -> File sz)

let line_type line =
  if string_match (regexp "^[0-9]+ .*$") line 0 then File_line
  else if line = "$ cd .." then Cd_Up
  else if line = "$ ls" then Ls
  else if string_match (regexp "\\$ cd .*") line 0 then Cd_Down
  else if string_match (regexp "^dir .*") line 0 then Dir_line
  else failwith (Printf.sprintf "Could not parse line %s" line)

let parse_dirname line = Scanf.sscanf line "$ cd %s" (fun s -> s)

let parse lines =
  let rec parse_dir lines (acc : fs_node list) =
    match lines with
    | [] -> (List.rev acc, [])
    | hd :: tl -> (
        match line_type hd with
        | Cd_Up -> (List.rev acc, tl)
        | File_line -> parse_dir tl (file_of_string hd :: acc)
        | Dir_line -> parse_dir tl acc
        | Ls -> parse_dir tl acc
        | Cd_Down ->
            let children, rest = parse_dir tl [] in
            let dirname = parse_dirname hd in
            parse_dir rest (Dir (dirname, children) :: acc))
  in
  let root_children, _ = parse_dir (List.tl lines) [] in
  Dir ("/", root_children)

let rec tabs n acc = match n with 0 -> acc | _ -> tabs (n - 1) (acc ^ "  ")

let rec print_dir d node =
  match node with
  | File sz -> print_endline (tabs d "" ^ Printf.sprintf "File with size %d" sz)
  | Dir (name, children) ->
      print_endline
        (tabs d "" ^ Printf.sprintf "Dir with name %s and children:" name);
      List.iter (print_dir (d + 1)) children

let part_one root = sum_children_leq 100000 root

let part_two root =
  let needed = 30000000 - (70000000 - size root) in
  let rec find_min acc root =
    match root with
    | File _ -> []
    | Dir (_, children) ->
        if needed - size root > 0 then []
        else size root :: List.flatten (List.map (find_min []) children)
  in
  let valid_dirs = find_min [] root in
  List.fold_left
    (fun acc elem -> if elem < acc then elem else acc)
    max_int valid_dirs

let run (spec : Runspec.spec) =
  let ic = open_in spec.filename in
  let input = Input.lines_of_in_channel ic in
  close_in ic;
  let root = parse input in
  print_endline (sprintf "Part 1: %d" (part_one root));
  print_endline (sprintf "Part 2: %d" (part_two root))
