#!/usr/bin/env ocaml

let dir_is_empty dir =
  Array.length (Sys.readdir dir) = 0

let print_list lst =
  List.iter print_endline lst

let list_files_by_extension dir ext =
  match dir_is_empty dir with
  | false ->
    Sys.readdir dir
    |> Array.to_list
    |> List.filter (fun x -> Filename.extension x = ext)
  | true  -> []

let read_file f =
  print_endline f;
  let ic = open_in f in
  let content = really_input_string ic (in_channel_length ic) in
  close_in ic;
  content

let () =
  match Array.to_list Sys.argv with
  | _ :: dir :: _ ->
    let files = list_files_by_extension dir ".toml" in
    if List.length files > 0 then
      let file_contents = List.map read_file files in
      print_list file_contents
    else
      print_endline "No files found"
  | _ -> print_endline "Please provide a directory as a command-line argument"
