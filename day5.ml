open Printf
open Scanf

type stack = char list
type instruction = { cnt : int; from_stack : int; to_stack : int }

let print_chars chars =
  let rec print_aux chars acc =
    match chars with
    | [] -> print_endline acc
    | hd :: tl -> (
        match hd with
        | ' ' -> print_aux tl (acc ^ "*")
        | _ -> print_aux tl (acc ^ String.make 1 hd))
  in
  print_aux chars ""

let take l n =
  let rec first_aux l acc n =
    match (l, n) with
    | [], _ -> (List.rev acc, [])
    | hd :: tl, 0 -> (List.rev acc, hd :: tl)
    | hd :: tl, _ -> first_aux tl (hd :: acc) (n - 1)
  in
  first_aux l [] n

let rec apply_instruction stacks instruction =
  match instruction.cnt with
  | 0 -> ()
  | _ -> (
      (* print_endline *)
      (*   (sprintf "Applying instruction cnt=%d, from=%d, to=%d" instruction.cnt *)
      (*      instruction.from_stack instruction.to_stack); *)
      (* print_endline "Current state: "; *)
      (* printf "From stack %d is now: " instruction.from_stack; *)
      (* print_chars stacks.(instruction.from_stack - 1); *)
      (* printf "To stack %d is now: " instruction.to_stack; *)
      (* print_chars stacks.(instruction.to_stack - 1); *)
      let from_stack = Array.get stacks (instruction.from_stack - 1) in
      let to_stack = Array.get stacks (instruction.to_stack - 1) in
      match from_stack with
      | [] ->
          failwith
            (sprintf "Cannot move anything from stack %d because it is empty"
               instruction.from_stack)
      | hd :: tl ->
          let new_instruction =
            {
              cnt = instruction.cnt - 1;
              from_stack = instruction.from_stack;
              to_stack = instruction.to_stack;
            }
          in
          let first, rest =
            take stacks.(instruction.from_stack - 1) instruction.cnt
          in
          Array.set stacks (instruction.to_stack - 1)
            (List.append first to_stack);
          Array.set stacks (instruction.from_stack - 1) rest;
          (* printf "From stack %d is now: " instruction.from_stack; *)
          (* print_chars stacks.(instruction.from_stack - 1); *)
          (* printf "To stack %d is now: " instruction.to_stack; *)
          (* print_chars stacks.(instruction.to_stack - 1); *)
          apply_instruction stacks new_instruction)

let rec apply_instruction_two stacks instruction =
  print_endline
    (sprintf "Applying instruction cnt=%d, from=%d, to=%d" instruction.cnt
       instruction.from_stack instruction.to_stack);

  let from_stack = Array.get stacks (instruction.from_stack - 1) in
  let to_stack = Array.get stacks (instruction.to_stack - 1) in
  printf "From stack %d is: " instruction.from_stack;
  print_chars from_stack;
  printf "To stack %d is: " instruction.to_stack;
  print_chars to_stack;
  match from_stack with
  | [] ->
      failwith
        (sprintf "Cannot move anything from stack %d because it is empty"
           instruction.from_stack)
  | hd :: tl ->
      let first, rest =
        take stacks.(instruction.from_stack - 1) instruction.cnt
      in
      Array.set stacks (instruction.to_stack - 1) (List.append first to_stack);
      Array.set stacks (instruction.from_stack - 1) rest;
      printf "From stack %d is: " instruction.from_stack;
      print_chars stacks.(instruction.from_stack - 1);
      printf "To stack %d is: " instruction.to_stack;
      print_chars stacks.(instruction.to_stack - 1)

let tops_of_stacks stacks = Array.map List.hd stacks

let parse_instruction line =
  let f cnt from_stack to_stack = { cnt; from_stack; to_stack } in
  sscanf line "move %d from %d to %d" f

let add_to_stack idx (char : char) (stacks : stack array) =
  let stack = Array.get stacks idx in
  match char with ' ' -> () | _ -> Array.set stacks idx (char :: stack)

let first l n =
  let rec first_aux l acc n =
    match (l, n) with
    | [], _ -> List.rev acc
    | _, 0 -> List.rev acc
    | hd :: tl, _ -> first_aux tl (hd :: acc) (n - 1)
  in
  first_aux l [] n

let chars_from_line maxlength line =
  let rec chars_aux line idx acc =
    match idx < maxlength with
    | false -> List.rev acc
    | true -> chars_aux line (idx + 1) (String.get line (1 + (4 * idx)) :: acc)
  in
  chars_aux line 0 []

let to_stacks charlists stack =
  let push_charlist charlist =
    let push_char i c =
      match c with ' ' -> () | _ -> stack.(i) <- c :: stack.(i)
    in
    List.iteri push_char charlist
  in
  List.iter push_charlist charlists;
  Array.iteri (fun i x -> stack.(i) <- List.rev stack.(i)) stack

let print_stacks stacks = Array.iter print_chars stacks

let only_lines lines =
  let rec aux lines acc =
    match lines with
    | [] -> List.rev acc
    | hd :: tl -> (
        let open Str in
        match string_match (regexp "^ 1") hd 0 with
        | true -> List.rev acc
        | false -> aux tl (hd :: acc))
  in
  aux lines []

let only_instructions lines =
  let rec aux lines acc =
    match lines with
    | [] -> List.rev acc
    | hd :: tl -> (
        let open Str in
        match string_match (regexp "^move") hd 0 with
        | true -> aux tl (hd :: acc)
        | false -> aux tl acc)
  in
  aux lines []

let run (spec : Runspec.spec) =
  let ic = open_in spec.filename in
  let input = Input.lines_of_in_channel ic in
  let charlists = List.map (chars_from_line 9) (only_lines input) in
  let stacks = Array.make 9 [] in
  let instructions = List.map parse_instruction (only_instructions input) in
  to_stacks charlists stacks;
  List.iter (apply_instruction_two stacks) instructions;
  let tops = tops_of_stacks stacks in
  print_endline "The answer is:";
  print_chars (List.init (Array.length tops) (fun i -> tops.(i)));
  close_in ic
