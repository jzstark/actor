(** [ Test coordinate descent ]  *)

module PS = Actor_param

let param = Array.(init 1000 (fun x -> x) |> to_list)

let pivot = ref 0

let schedule workers =
  Owl_log.debug "scheduling ...";
  let tasks = List.map (fun x ->
    let k, v = !pivot, 0.5 in
    pivot := !pivot + 1;
    (x, [(k,v)])
  ) workers in
  Owl_log.debug "scheduling done ...";
  tasks

let push = None

let pull = None

let test_coordinate_descent () =
  PS.register_schedule schedule;
  PS.start Sys.argv.(1) Actor_config.manager_addr;
  Owl_log.info "do some work at master node"

let _ = test_coordinate_descent ()
