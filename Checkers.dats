#include
"share/atspre_define.hats"
#include
"share/atspre_staload.hats"

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
  val () = cairo_move_to(cr, x*scale, y*scale)
  val () = cairo_line_to(cr, (x+1)*scale, y*scale)
  val () = cairo_line_to(cr, (x+1)*scale, (y+1)*scale)
  val () = cairo_line_to(cr, x*scale, (y+1)*scale)
  val () = cairo_line_to(cr, x*scale, y* scale)
  val () = cairo_stroke(cr)
in
end

implement
draw_board{l}(cr, highlight, cursor) = 
let
  // assuming that user space is scaled by now
  val () = cairo_rectangle(cr, 0.0, 0.0, 1.0, 1.0)
  val () = cairo_set_source_rgb(cr, 0.8, 0.0, 0.0) // red
  fun loop(cr: !cairo_ref1, row: int, col: int): void = 
  let
    val fact = (if (row > col) then (row - col) else (col - row)):int
    val r = 0.8 - (0.8 * ((fact) mod 2)) // I hate using if statements
    val scale = 0.125 //dividing board into eighths
    val () = cairo_rectangle(cr, row * scale, col * scale, (row + 1.0) * scale, (col + 1.0) * scale)
    val () = cairo_set_source_rgb(cr, r, 0.0, 0.0)
    val () = cairo_fill(cr)
  in
    case+ (row, col) of
    | (7, 7) => 
    let
      val () = draw_square(cr, highlight, 0.7, 0.7, 0.0)
      val () = draw_square(cr, cursor, 0.1, 0.1, 0.7)
    in
    end
    | (i, 7) => loop(cr, i+1, 0)
    | (i, j) => loop(cr, i, j+1)
  end
in
  loop(cr, 0, 0)
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

implement{a:t@ype}
listSet(ls, n, item) = 
let
  fun loop(ls: list0 (a), head: list0(a), n: int, item: a): list0 (a) = 
  let
    val-list0_cons(x, xs) = ls
  in
    (if (n = 0) then list0_append(list0_reverse(list0_cons(item, head)), xs) else loop(xs, list0_cons(x, head), n -1, item)): list0 (a)
  end 
in
  loop(ls, list0_nil (), n, item)
end

implement
board_set_at(b, s, i, j) = 
let
  val list = listGet<list0 (square)>(b, i)
  val nlist = listSet<square>(list, j, s)
in
  listSet(b, i, nlist)
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
  val my = (sy - dy):int
  val valid = valid && ((king || (mx < 0 && black)) || (mx > 0 && ~black))
  val valid = valid && (((mx/my) = 1) || ((mx/my) = ~1))
  val skip = (mx = 2 || mx = ~2)
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


// --------Included for testing purposes only--------

implement
mydraw{l}(cr, width, height) = 
let
  val () = cairo_scale(cr, width*1.0, height*1.0)
  val () = draw_board(cr, L(1,2), L(2,1))
in
end

