let day_of_int day_num : Runspec.spec -> unit =
  match day_num with
  | 1 -> Day1.run
  | 2 -> Day2.run
  | 3 -> Day3.run
  | 4 -> Day4.run
  | 5 -> Day5.run
  | 6 -> Day6.run
  | 7 -> Day7.run
  | n ->
      failwith
        (Format.sprintf "Have not implemented solution for day %d yet." n)

let () =
  let spec = Runspec.make Sys.argv in
  (day_of_int spec.day) spec
