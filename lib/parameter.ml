(** [ Parameter Server ]
  provides a global variable like kv store
*)

open Types

let _param : (Obj.t, Obj.t * int) Hashtbl.t = Hashtbl.create 1_000_000
let _ztx = ZMQ.Context.create ()
let _ps : [`Dealer] ZMQ.Socket.t = ZMQ.Socket.(create _ztx dealer)
let _ = ZMQ.Socket.connect _ps Config.ps_addr


let _get k t =
  let v, t' = Hashtbl.find _param (Obj.repr k) in
  Logger.debug "%i" (t' - t);
  v

let _set k v t =
  let v, t' = Hashtbl.find _param (Obj.repr k) in
  Logger.debug "%i" (t' - t);
  Hashtbl.replace _param (Obj.repr k) (v, t)

let get = None

let set k v t =
  Logger.info "%s" ("SET @ ???");
  let k' = Marshal.to_string k [] in
  let v' = Marshal.to_string v [] in
  Utils.send ~bar:t _ps PS_Set [|k'; v'|]

let schedule x = None

let service () =
  let _router = ZMQ.Socket.(create _ztx router) in
  ZMQ.Socket.bind _router Config.ps_addr;
  ZMQ.Socket.set_receive_high_water_mark _router Config.high_warter_mark;
  Logger.info "%s" "parameter server starts ...";
  try while true do
    let i, m = Utils.recv _router in
    let t = m.bar in
    match m.typ with
    | PS_Get -> (
      Logger.info "GET t:%i @ %s" t Config.ps_addr
      )
    | PS_Set -> (
      Logger.info "SET t:%i @ %s" t Config.ps_addr
      
      )
    | _ -> (
      Logger.debug "%s" "unknown mssage to PS";
      )
  done with Failure e -> (
    Logger.warn "%s" e;
    ZMQ.Socket.close _router;
    Pervasives.exit 0 )


(** start parameter server *)

let _ = if Array.length Sys.argv > 1 then
  match Sys.argv.(1) with
  | "start" -> service ()
  | _ -> ()