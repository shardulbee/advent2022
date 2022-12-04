main: *.ml
	ocamlopt str.cmxa -o advent2022 runspec.ml input.ml day*.ml main.ml
