#include
"share/atspre_define.hats"
#include
"share/atspre_staload.hats"
#include
"share/atspre_staload_libats_ML.hats"

%{^
#include "Checkers.cats"
%}

staload "{$CAIRO}/SATS/cairo.sats"
staload "./Checkers.sats"
staload "libats/ML/SATS/basis.sats"
staload "libats/ML/SATS/list0.sats"
staload _(*anon*) = "libats/ML/DATS/list0.dats"

// --------Actual Code-------- 


implement
draw_square{l}(cr, loc, r, g, b) =
let
  val () = cairo_set_line_width(cr, 0.004)
  val () = cairo_set_source_rgb(cr, r, g, b)
  val scale = 0.125
  val-L(x, y) = loc
  val good = (x >= 0) && (y >= 0)
in
  case+ good of
  | true =>
  let
    val () = cairo_move_to(cr, x*scale, y*scale)
    val () = cairo_line_to(cr, (x+1)*scale, y*scale)
    val () = cairo_line_to(cr, (x+1)*scale, (y+1)*scale)
    val () = cairo_line_to(cr, x*scale, (y+1)*scale)
    val () = cairo_line_to(cr, x*scale, y* scale)
    val () = cairo_stroke(cr)
  in
  end
  | false => ()
// in
end

implement
draw_crown{l}(cr,loc) = 
let
	var scale = 0.125
	val-L (x,y) = loc
	val () = cairo_set_line_width(cr,0.004)
	val () = cairo_set_source_rgb(cr,1.0,0.8,0.2)
	val () = cairo_move_to(cr, (x+0.25)*scale, (y+0.33)*scale)
	val () = cairo_line_to(cr, (x+0.32)*scale, (y+0.41)*scale)
	val () = cairo_line_to(cr, (x+0.39)*scale, (y+0.25)*scale)
	val () = cairo_line_to(cr, (x+0.46)*scale, (y+0.41)*scale)
	val () = cairo_line_to(cr, (x+0.53)*scale, (y+0.25)*scale)
	val () = cairo_line_to(cr, (x+0.60)*scale, (y+0.41)*scale)
	val () = cairo_line_to(cr, (x+0.67)*scale, (y+0.25)*scale)
	val () = cairo_line_to(cr, (x+0.74)*scale, (y+0.33)*scale)
	val () = cairo_line_to(cr, (x+0.74)*scale, (y+0.66)*scale)
	val () = cairo_line_to(cr, (x+0.25)*scale, (y+0.66)*scale)
	val () = cairo_fill(cr)
in
end

implement
draw_piece{l}(cr, loc, sq) =
let
  val-S (e,color,king) = sq
in
  case+ e of
  | false => ()
  | true => 
  let
    val-L (x,y) = loc
    var scale = 0.125
    val () = cairo_set_line_width(cr,0.008)
    val () = (if (color = true) then cairo_set_source_rgb(cr,0.0,0.0,0.0) else cairo_set_source_rgb(cr,0.4,0.0,0.0)):void
    val () = cairo_arc(cr, x*scale + (scale/2),y*scale + (scale/2),0.06,0.0,6.288)
    val () = cairo_stroke_preserve(cr)
    val () = (if (color = true) then cairo_set_source_rgb(cr,0.1,0.1,0.1) else cairo_set_source_rgb(cr,0.45,0.0,0.02)):void
    val () = cairo_fill(cr)
    val () = (if (king = true) then draw_crown(cr,loc) else ()) :void
  in
  end
end


implement
draw_board{l}(cr, b, highlight, cursor) = 
let
  // assuming that user space is scaled by now
  val () = cairo_rectangle(cr, 0.0, 0.0, 1.0, 1.0)
  val () = cairo_set_source_rgb(cr, 0.8, 0.0, 0.0) // red
  fun loop(cr: !cairo_ref1, b: board, row: int, col: int): void = 
  let
    val fact = (if (row > col) then (row - col) else (col - row)):int
    val r = 0.8 - (0.8 * ((fact) mod 2)) // I hate using if statements
    val scale = 0.125 //dividing board into eighths
    val () = cairo_rectangle(cr, row * scale, col * scale, (row + 1.0) * scale, (col + 1.0) * scale)
    val () = cairo_set_source_rgb(cr, r, 0.0, 0.0)
    val () = cairo_fill(cr)
    val-S (thex, thbl, thki) = board_get_at(b, row, col)
    val () = draw_piece(cr, L(row, col), S(thex, thbl, thki))
  in
    case+ (row, col) of
    | (7, 7) => 
    let
	  val () = draw_square(cr, cursor, 0.1, 0.1, 0.7)
      val () = draw_square(cr, highlight, 0.7, 0.7, 0.0)
    in
    end
    | (i, 7) => loop(cr, b, i+1, 0)
    | (i, j) => loop(cr, b, i, j+1)
  end
in
  loop(cr, b, 0, 0)
end

implement{a:t@ype}
listGet(ls, n) = 
let
  val-list0_cons (x, xs) = ls
in
  case+ n of
  | 0 => x
  | _ => listGet(xs, n -1)
end

implement
board_get_at(b, i, j) =
let
in
  listGet<square>(listGet<list0 (square)>(b, i), j)
end

implement
board_set_at(b, s, i, j) = 
let
  val list = list0_get_at_exn(b, i) // listGet<list0 (square)>(b, i)
  val nlist = list0_insert_at_exn(list, j, s)
  val nlist = list0_remove_at_exn(nlist, j+1)
  val b = list0_insert_at_exn(b, i, nlist)
in
  list0_remove_at_exn(b, i+1)
end

implement
check_jump(b, bl, ox, oy, dx, dy) = 
let
  val-S(tesex, tesbl, teski) = board_get_at(b, dx, dy)
  val-S(jex, jbl, jki) = board_get_at(b, ox, oy) // piece in between
  val res = ((jex && ~tesex) && ((jbl && ~bl) || (~jbl && bl)))
in
  res
end

implement
can_piece_jump(b, s, loc) = 
let
  val-L(lx, ly) = loc
  val-S(ex, bl, ki) = s
  val res = false
  val dir = (if (bl) then ~1 else 1):int // black goes up the board, red down
  val dir2 = (if (ki) then ~dir else dir):int //kings go everywhere
  val left = L(lx + ~2, ly + 2*dir)
  val right = L(lx + 2, ly + 2*dir)
  val kl = L(lx + ~2, ly + 2*dir2) // possibly redundant, but that's ok
  val kr = L(lx + 2, ly + 2*dir2)
  val-L(lefx, lefy) = left
  val-L(rigx, rigy) = right
  val-L(kilx, kily) = kl
  val-L(kirx, kiry) = kr
  val resln = (if ( lefx < 0 || (lefy < 0 || lefy > 7)) then false else check_jump(b, bl, lefx + 1, lefy - dir, lefx, lefy)):bool
  val resrn = (if ( rigx > 7 || (rigy < 0 || rigy > 7)) then false else check_jump(b, bl, rigx - 1, rigy - dir, rigx, rigy)):bool
  val reslk = (if ( kilx < 0 || (kily < 0 || kily > 7)) then false else check_jump(b, bl, kilx + 1, kily - dir, kilx, kily)):bool
  val resrk = (if ( kirx > 7 || (kiry < 0 || kiry > 7)) then false else check_jump(b, bl, kirx - 1, kiry - dir, kirx, kiry)):bool
  val res = (res || (resln || (resrn || (reslk || resrk))))
in
  res
end

implement
can_player_jump(b, bl, i, j) =
let
  val-S(tex, tbl, tking) = board_get_at(b, i ,j)
  val now = (if (tex && (bl = tbl)) then (can_piece_jump(b, S(tex, tbl, tking), L(i, j))) else (false)):bool
in
  case+ (i, j) of
  | (7, 7) => now
  | (i, 7) => now || can_player_jump(b, bl, i+1, 0)
  | (i, j) => now || can_player_jump(b, bl, i, j+1)
end

implement
legal_move(b, source, dest) = 
let
  val-L(sx, sy) = source
  val-L(dx, dy) = dest
  val-S(exist,black,king) = board_get_at(b, sx, sy) // listGet<square>(listGet<list0 (square)>(b, sx), sy)
  val valid = exist
  val-S(dex,dr,dk) = board_get_at(b, dx, dy) // listGet<square>(listGet<list0 (square)>(b, dx), dy)
  val valid = valid && ~dex
  val mx = sx - dx
  val my = sy - dy
  val valid = valid && ((king || (my > 0 && black)) || (my < 0 && ~black))
  val valid = valid && (((mx/my) = 1) || ((mx/my) = ~1))
  val skip = (mx = 2 || mx = ~2)
  val valid = valid && ((skip && can_player_jump(b, true, 0, 0)) || (~skip))
  val taking = (if (skip) then (
      let
        val-S(tex,tr,tk) = board_get_at(b, sx + (mx/2), sy + (my/2)) // listGet<square>(listGet<list0 (square)>(b, sx + (mx/2)), sy + (my/2))
	val took = tex && ((tr && ~black) || (~tr && black))
      in
        took
      end
      ) 
    else true):bool
  val valid = valid && taking
in 
  valid
end

implement
get_all_jumps(b, bl, ls, i, j) = 
let
  val-S(tex, tbl, tki) = board_get_at(b, i, j)
  val ss = S(tex, tbl, tki)
  val ll = L(i, j)
  val boo = (tbl = bl) && can_piece_jump(b, ss, ll)
  val vls = list0_insert_at_exn(ls, 0, ll) //ATS compiler wasn't liking list0_cons(ss, ls) for whatever reason
  val nls = (if (boo) then (vls) else (ls)):list0(location)
in
  case+ (i, j) of
  | (7, 7) => (nls)
  | (i, 7) => (get_all_jumps(b, bl, nls, i+1, 0))
  | (i, j) => (get_all_jumps(b, bl, nls, i, j+1))
end


(*
Order of desired moves:
1. Take an enemy king
2. Take an enemy piece where the enemy can't take your piece (Ignoring this for one for now)
3. Take an enemy piece
4. Block the enemy from taking a piece (ignoring this one for now)
5. Move a piece forward
*)

// fix to move kings on occasion, and do all parts of a multi-jump
implement
get_CPU_move(B) = 
let
  val ls = get_all_jumps(B, true, list0_nil(), 0, 0)
  fun makeJump(b: board, ls: list0(location), bestSt: location, bestDs: location, rank: int): board = 
  (
    case+ ls of
    | list0_nil () => if (rank < 4) then (* found a jump *)
      let
        val-L(sx, sy) = bestSt
        val-L(dx, dy) = bestDs
      	val (mx, my) = ((dx-sx)/2, (dy-sy)/2)
      	val-S(sex, sbl, ski) = board_get_at(b, sx, sy)
      	val b = board_set_at(b, S(false, sbl, ski), sx, sy)
      	val b = board_set_at(b, S(false, false, false), sx+mx, sy+my)
      	val b = board_set_at(b, S(sex, sbl, ski), dx, dy)
      in
        b
      end
    else b
    | list0_cons(x, xs) => 
    let 
      val nrank = 3 // this is at least a valid jump 
      val-L(xx, xy) = x // location of the square we're jumping from
      val-S (sex, sbl, ski) = board_get_at(b, xx, xy)
      val dir = (if sbl then ~1 else 1):int
      val dir2 = (if ski then ~dir else dir):int
      //now we want to figure out what jump we can attempt
      val mvln = ((xx - 2) >= 0) && ((xy + 2*dir >= 0) && (xy + 2*dir <= 7)) // can jump left and normally
      val mvrn = ((xx + 2) <= 7) && ((xy + 2*dir >= 0) && (xy + 2*dir <= 7)) // can jump right and normally
      val mvlk = ((xx - 2) >= 0) && ((xy + 2*dir2 >= 0) && (xy + 2*dir2 <= 7)) // can jump left and kingly
      val mvrk = ((xx + 2) <= 7) && ((xy + 2*dir2 >= 0) && (xy + 2*dir2 <= 7)) // can jump right and kingly
      // now we want to see if an attempted jump is jump, and if so, make this the value we'll recurse upon, re-ranking as needed
      // first find kings to jump, if any are
      val lniski = 
        (if mvln then 
        let
	  val-S(tex, tbl, tki) = board_get_at(b, xx-1, xy+dir)
	in
	  tex && tki
	end
	else false):bool
      val rniski = 
        (if mvrn then 
        let
	  val-S(tex, tbl, tki) = board_get_at(b, xx+1, xy+dir)
	in
	  tex && tki
	end
	else false):bool
      val lkiski = 
        (if mvlk then 
        let
	  val-S(tex, tbl, tki) = board_get_at(b, xx-1, xy+dir2)
	in
	  tex && tki
	end
	else false):bool
      val rkiski = 
        (if mvrk then 
        let
	  val-S(tex, tbl, tki) = board_get_at(b, xx+1, xy+dir2)
	in
	  tex && tki
	end
	else false):bool
      val nrank = (if (lniski || (rniski || (lkiski || rkiski))) then 1 else nrank):int
	// now if there is a king we definitely want to jump
    in
       case+ (lniski, rniski, lkiski, rkiski) of
      | (true, _, _, _) => makeJump(b, xs, x, L(xx - 2, xy + 2*dir), nrank)
      | (_, true, _, _) => makeJump(b, xs, x, L(xx + 2, xy + 2*dir), nrank)
      | (_, _, true, _) => makeJump(b, xs, x, L(xx - 2, xy + 2*dir2), nrank)
      | (_, _, _, true) => makeJump(b, xs, x, L(xx + 2, xy + 2*dir2), nrank)
      | (_, _, _, _) => 
      (
        case+ (mvln, mvrn, mvlk, mvrk) of
	| (true, _, _, _) => (if nrank < rank then makeJump(b, xs, x, L(xx - 2, xy + 2*dir), nrank) else makeJump(b, xs, bestSt, bestDs, rank)): board
        | (_, true, _, _) => (if nrank < rank then makeJump(b, xs, x, L(xx + 2, xy + 2*dir), nrank) else makeJump(b, xs, bestSt, bestDs, rank)): board
      	| (_, _, true, _) => (if nrank < rank then makeJump(b, xs, x, L(xx - 2, xy + 2*dir2), nrank) else makeJump(b, xs, bestSt, bestDs, rank)): board
      	| (_, _, _, _) => (if nrank < rank then makeJump(b, xs, x, L(xx + 2, xy + 2*dir2), nrank) else makeJump(b, xs, bestSt, bestDs, rank)): board	
      )
    end
  )
in
  case+ ls of
  | list0_cons(_, _) => makeJump(B, ls, L(0,0), L(0,0), 4)
  | list0_nil () => (*no jump to make, just move the furthest forward piece forward*)
  let
    fun movePiece(b: board, i: int, j: int): board =
    let
      val-S(thex, thbl, thki) = board_get_at(b, i, j)
      val pos = thex && ~thbl
      val dir = (if thbl then ~1 else 1):int
      val dir2 = (if thki then ~dir else dir):int
      val (lnx, lny) = (if((i - 1 >= 0) && ((j + dir >= 0) && (j + dir <= 7))) then (i-1, j+dir) else (i, j)): (int, int)
      val (rnx, rny) = (if((i + 1 <= 7) && ((j + dir >= 0) && (j + dir <= 7))) then (i+1, j+dir) else (i, j)): (int, int)
      val (lkx, lky) = (if((i - 1 >= 0) && ((j + dir2 >= 0) && (j + dir2 <= 7))) then (i-1, j+dir2) else (i, j)): (int, int)
      val (rkx, rky) = (if((i + 1 <= 7) && ((j + dir2 >= 0) && (j + dir2 <= 7))) then (i+1, j+dir2) else (i, j)): (int, int)
      val-S(tex, tbl, tki) = board_get_at(b, lnx, lny)
      val lnopen = ~tex
      val-S(tex, tbl, tki) = board_get_at(b, rnx, rny)
      val rnopen = ~tex
      val-S(tex, tbl, tki) = board_get_at(b, lkx, lky)
      val lkopen = ~tex
      val-S(tex, tbl, tki) = board_get_at(b, rkx, rky)
      val rkopen = ~tex
      val pos = pos && (lnopen || (rnopen || (lkopen || rkopen)))
    in
      if pos then
      (
        case+ (lnopen, rnopen, lkopen, rkopen) of
	| (true, _, _, _) =>
	let
	  val b = board_set_at(b, S(false, thbl, thki), i, j)
	  val b = board_set_at(b, S(true, thbl, thki), lnx, lny) 
	in
	  b
	end  
	| (_, true, _, _) =>
	let
	  val b = board_set_at(b, S(false, thbl, thki), i, j)
	  val b = board_set_at(b, S(true, thbl, thki), rnx, rny) 
	in
	  b
	end
	| (_, _, true, _) =>
	let
	  val b = board_set_at(b, S(false, thbl, thki), i, j)
	  val b = board_set_at(b, S(true, thbl, thki), lkx, lky) 
	in
	  b
	end
	| (_, _, _, _) => 
	let
	  val b = board_set_at(b, S(false, thbl, thki), i, j)
	  val b = board_set_at(b, S(true, thbl, thki), rkx, rky) 
	in
	  b
	end
      )
      else
      (
        case+ (i, j) of
	| (0,0) => b
	| (i,0) => movePiece(b, i-1, 7)
	| (i,j) => movePiece(b, i, j-1)
      )
    end
  in
    movePiece(B, 7, 7)
  end
end
