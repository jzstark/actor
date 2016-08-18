(** [ DAG module ]
  maintains a directed acyclic graph of computation.
*)

open Types

type vlabel = { c : color; f : string }

module Digraph = struct
  module V' = struct
    type t = string
    let hash = Hashtbl.hash
    let equal = (=)
    let compare = Pervasives.compare
  end
  module E' = struct
    type t = int
    let compare = Pervasives.compare
    let default = 0
  end
  include Graph.Imperative.Digraph.ConcreteLabeled (V') (E')
end

module TopoOrd = Graph.Topological.Make_stable (Digraph)

let _graph = ref (Digraph.create ())

let _vlabel : vlabel StrMap.t ref = ref StrMap.empty

let get_vlabel_f x = (StrMap.find x !_vlabel).f

let add_edge f u v c =
  if (StrMap.mem u !_vlabel) = false then
    _vlabel := StrMap.add u { c = Green; f = "" } !_vlabel;
  _vlabel := StrMap.add v { c = c; f = f } !_vlabel;
  Digraph.add_edge !_graph u v

let stages () =
  let r, s = ref [], ref [] in
  let _ = TopoOrd.iter (fun v ->
    match (StrMap.find v !_vlabel).c with
    | Blue -> s := !s @ [v]; r := !r @ [!s]; s := []
    | Red -> s := !s @ [v]
    | Green -> ()
  ) !_graph in
  if List.length !s = 0 then !r else !r @ [!s]

let mark_stage_done s =
  List.iter (fun k ->
    let v = StrMap.find k !_vlabel in
    _vlabel := StrMap.add k { c = Green; f = v.f } !_vlabel
  ) s

(* FIXME: the following functions are for debugging *)

let print_vertex v =
  let x = StrMap.find v !_vlabel in
  match x.c with
  | Red -> Printf.printf "(%s, Red); " v
  | Green -> Printf.printf "(%s, Green); " v
  | Blue -> Printf.printf "(%s, Blue); " v

let print_stages x =
  print_endline "";
  List.iter (fun l ->
    print_string "stage: ";
    List.iter (fun v ->
      print_vertex v
    ) l; print_endline ""
  ) x

let print_tasks () = TopoOrd.iter (fun v -> print_vertex v) !_graph
