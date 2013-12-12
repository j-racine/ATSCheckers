// copied from assignment7 test.dats

#include
"share/atspre_define.hats"
#include
"share/atspre_staload.hats"

dynload "./Checkers.dats"
staload "libats/ML/SATS/basis.sats"
staload "libats/ML/SATS/list0.sats"
staload _ = "libats/ML/DATS/list0.dats"
staload "./Checkers.sats"
staload "{$CAIRO}/SATS/cairo.sats"

staload
UN = "prelude/SATS/unsafe.sats"

(* ****** ****** *)

(* ****** ****** *)

extern
fun init_board(): board

extern
fun col_loop(col: list0(square), i: int, j: int): list0(square)

implement
col_loop (col, i, j) = 
let
  val ex_here = (((i mod 2) = (j mod 2)) && ((j < 3) || (j > 4)))
  val black = (j > 4)
  val king = false
  val sq = S(ex_here, black, king)
  val nls = list0_cons{square}(sq, col)
in
  case+ j of
  | 7 => nls
  | _ => col_loop(nls, i, j+1)
end

extern
fun board_loop(b: board, i: int): board

implement
board_loop(b, i) = 
let
  val col = list0_reverse(col_loop(list0_nil (), i, 0))
  val b = list0_cons{list0 (square)}(col, b)
in
  case+ i of
  | 7 => b
  | _ => board_loop(b, i+1)
end

implement
init_board() = 
let
in
  (board_loop(list0_nil (), 0))
end

extern
fun init_ptr(): board_ptr

local

assume board_ptr = '{b= ref (board)}
assume boolean_ptr = '{boolean= ref (bool)}
assume loc_ptr = '{loc= ref (location)}

in

implement
init_ptr() =
let 
in
  '{b= ref (init_board())} 
end

implement
mydraw{l}(cr, width, height, b, pl, cur, high, mid, time) = 
let
  val () = cairo_scale(cr, width*1.0, height*1.0)
  val () = draw_board(cr, !(b.b), !(high.loc), !(cur.loc)) 
in
  case+ !(pl.boolean) of
  | true =>
  let
    val input = (if (((time mod 3) = 2)) then key_get() else ~1):int
    val cval = cur.loc
    val hval = high.loc
    val cloc = !cval
    val hloc = !hval
    val-L(cx, cy) = cloc
    val my = (if (input = 119) then ~1 else 0):int
    val my = (if (input = 115) then 1 else my):int
    val mx = (if (input = 97) then ~1 else 0):int
    val mx = (if (input = 100) then 1 else mx):int
    val cx = (if ((cx+mx > 7) || (cx+mx < 0)) then cx else cx+mx):int
    val cy = (if ((cy+my > 7) || (cy+my < 0)) then cy else cy+my):int
    val () = !cval := L(cx, cy)
    val-L(hx, hy) = hloc
    val update = (((hx = ~1) && (hy = ~1)) && (input = 32))
  in
    case+ update of
    | true => 
    let
      val () = !hval := L(cx, cy)
    in
    end
    | false => 
    let
      val valid = (if (hx > ~1) then legal_move(!(b.b), L(hx, hy), L(cx, cy)) else false):bool
      val () = (if (can_player_jump(!(b.b), true, 0, 0) && ((hx mod 2) = (cx mod 2))) then print_int(1) else ()):void
      val valid = valid && ((can_player_jump(!(b.b), true, 0, 0) && ((hx mod 2) = (cx mod 2))) || (~can_player_jump(!(b.b), true, 0, 0) && ~((hx mod 2) = (cx mod 2))))
      val () = (if valid then print_int(2) else ()):void
      val-L(spx, spy) = !(mid.loc)
      val valid = (if (spx > ~1) then (valid && ((spx = hx) && (spy = hy))) else valid):bool
    in
      case+ valid of
      | false => 
      let
        val () = (if (input = 32) then !hval := L(~1, ~1) else ()):void
      in
      end
      | true => (if ~(input = 32) 
      then () 
      else 
      let
      // should check mid first before doing jump
        val mx = cx - hx
	val my = cy - hy
	val pc = board_get_at(!(b.b), hx, hy)
	val newb = board_set_at(!(b.b), S(false, false, false), hx, hy)
	val newb = (if ((mx = ~2) || (mx = 2)) then board_set_at(newb, S(false, false, false), (cx+hx)/2, (cy+hy)/2) else newb):board
	val newb = board_set_at(newb, pc, cx, cy)
	val () = !(b.b) := newb
	val cont = can_player_jump(newb, true, 0, 0)
	val spec = (if cont then L(cx, cy) else L(~1,~1)):location
	val () = !(mid.loc) := spec
	val () = !(pl.boolean) := false
	val () = !(high.loc) := L(~1, ~1)
      in
      end):void
    end
  end 
  | false => 
  let
    val newb = get_CPU_move(!(b.b))
    val () = !(b.b) := newb
    val () = !(pl.boolean) := true
  in
  end
end

(* ****** ****** *)

%{^
typedef char **charptrptr ;
%} ;
abstype charptrptr = $extype"charptrptr"

(* ****** ****** *)

staload "/cs/coursedata/cs520/Fall13/myGTK/SATS/gtkcairoclock.sats"
staload _ = "/cs/coursedata/cs520/Fall13/myGTK/DATS/gtkcairoclock.dats"

(* ****** ****** *)

val the_ntimeout_ref = ref<int> (0)
// val board_ref = ref<board> (init_board())
val new_board = init_ptr()
val turn_ptr = '{boolean= ref<bool> (true)}
val curs_ptr = '{loc= ref<location> (L(3,3))}
val high_ptr = '{loc= ref<location> (L(~1, ~1))}
val mid_ptr = '{loc= ref<location> (L(~1, ~1))}

(* ****** ****** *)

implement
main0 (argc, argv) =
{
//
var argc: int = argc
var argv: charptrptr = $UN.castvwtp1{charptrptr}(argv)
//
val () = $extfcall (void, "gtk_init", addr@(argc), addr@(argv))
//
implement
gtkcairoclock_title<> () = stropt_some"Checkers"
implement
gtkcairoclock_timeout_update<> () = !the_ntimeout_ref := !the_ntimeout_ref + 1
implement
gtkcairoclock_timeout_interval<> () = 50U (* millisecs *)
implement
gtkcairoclock_mydraw<> (cr, W, H) = mydraw (cr, W, H, new_board, turn_ptr, curs_ptr, high_ptr, mid_ptr, !the_ntimeout_ref)
//
val ((*void*)) = gtkcairoclock_main ((*void*))
//
} (* end of [main0] *)

end
(* ****** ****** *)

(* end of [test.dats] *)
