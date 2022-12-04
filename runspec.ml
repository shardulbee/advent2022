type spec = { filename : string; day : int }

let make argv =
  let day_num =
    try int_of_string (Array.get argv 1)
    with Invalid_argument _ -> failwith "Must provide day number."
  in
  let filename =
    try Array.get argv 2
    with Invalid_argument _ -> failwith "Must provide input file."
  in
  { filename; day = day_num }
