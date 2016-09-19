(** [ Test parameter server ]  *)

module PS = Parameter

let test_store () =
  let _ = PS.set (1,1) "abcd" in
  let _ = PS.get (1,1) in
  Logger.debug "%s" "test done"

let schedule workers =
  let l = List.length workers in
  let x = Random.int l in
  let y = (x + 1) mod l in
  [ (List.nth workers x, [(1,"task1")]); (List.nth workers y, [(2,"task2")]) ]

let push id vars =
  let updates = List.map (fun (k,v) ->
    Logger.info "working on %s" v;
    (k,v) ) vars in
  updates

let test_context () =
  PS.register_schedule schedule;
  PS.register_push push;
  PS.init Sys.argv.(1) Config.manager_addr;
  Logger.info "do some work at master node"

let _ = test_context ()
