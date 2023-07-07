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
    |> List.filter (fun f -> Filename.extension f = ext)
    |> List.map (fun f -> Printf.sprintf "%s/%s" dir f) 
  | true  -> []

let read_file f =
   Printf.printf "reading file: %s\n" f;
  let ic = open_in f in
  let content = really_input_string ic (in_channel_length ic) in
  close_in ic;
  content

let merge_files_content c =
  String.concat "\n" c

let create_file_with_extension d n c e =
  let f = Printf.sprintf "%s%s%s" d n e in
  let oc = open_out f in
  output_string oc c;
  Printf.printf "saving into file: %s\n" f;
  close_out oc

let run dir_in dir_out =
  match list_files_by_extension dir_in ".toml" with
    | [] -> print_endline "No files found"
    | files ->
        let file_contents = List.map read_file files in
        let merged = merge_files_content (List.rev file_contents) in
        create_file_with_extension dir_out "config" merged ".toml";
        print_list file_contents

let () =
  match Sys.argv with
  | [|_; dir_in; dir_out |] -> run dir_in dir_out
  | _ -> print_endline "Please provide a directory as a command-line argument"